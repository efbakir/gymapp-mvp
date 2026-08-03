//
//  StoreManager.swift
//  Unit
//
//  Handles StoreKit 2 product loading, purchasing, and restore
//  for Unit's subscription tiers plus optional Lifetime purchase.
//  Pricing authority: docs/pricing.md.
//

import StoreKit
import OSLog

/// Prevents an entitlement refresh that started before a purchase completed
/// from overwriting that newer, authoritative transaction with a stale
/// "nothing active" result.
struct EntitlementRefreshState {
    private(set) var revision = 0

    func beginRefresh() -> Int {
        revision
    }

    mutating func recordAuthoritativeChange() {
        revision &+= 1
    }

    func canApplyEmptyResult(from refreshRevision: Int) -> Bool {
        refreshRevision == revision
    }
}

@MainActor
@Observable
final class StoreManager {
    // MARK: - Product IDs

    enum Tier: String, CaseIterable, Identifiable, Sendable {
        case weekly = "com.unit.weekly"
        case monthly = "com.unit.monthly"
        case annual = "com.unit.annual"
        case lifetime = "com.unit.lifetime"

        var id: String { rawValue }

        var isSubscription: Bool {
            switch self {
            case .weekly, .monthly, .annual: true
            case .lifetime: false
            }
        }
    }

    nonisolated static let weeklyProductID = Tier.weekly.rawValue
    nonisolated static let monthlyProductID = Tier.monthly.rawValue
    nonisolated static let annualProductID = Tier.annual.rawValue
    nonisolated static let lifetimeProductID = Tier.lifetime.rawValue

    nonisolated static let requiredTiers: [Tier] = [
        .weekly,
        .monthly,
        .annual
    ]

    nonisolated private static let allProductIDs: [String] = [
        Tier.weekly.rawValue,
        Tier.monthly.rawValue,
        Tier.annual.rawValue,
        Tier.lifetime.rawValue
    ]

    /// Last entitlement answer, persisted across launches. Absent = StoreKit
    /// has never answered on this install; "" = answered "no entitlement";
    /// otherwise a `Tier` rawValue. Lets the launch gate open from the cached
    /// answer instead of blocking on `Transaction.currentEntitlements`, which
    /// can hang indefinitely (wedged simulator StoreKit session, broken App
    /// Store connection).
    nonisolated private static let lastKnownEntitlementKey = "storeManager.lastKnownEntitlement"

    /// How long the first-ever entitlement check may block the launch gate
    /// before the app gives up and shows the paywall. The check keeps running
    /// and corrects the state whenever it completes.
    nonisolated private static let entitlementGateTimeout: Duration = .seconds(5)

    // MARK: - State

    var products: [String: Product] = [:]
    /// Product IDs whose StoreKit introductory offer is a free trial and
    /// whose subscription group is eligible for this Apple Account.
    /// StoreKit remains the authority; the paywall never guesses eligibility.
    var freeTrialEligibleProductIDs: Set<String> = []
    var isLoading = false
    var hasAttemptedProductLoad = false
    var isPurchased = false
    var activeTier: Tier?
    /// Flips true the first time `checkEntitlement()` completes (success or no
    /// entitlement). Read by `ContentView` to avoid flashing the hard paywall
    /// over `mainTabView` on cold launch before the StoreKit check returns.
    var hasCheckedEntitlement = false
    var purchaseError: String?
    /// Non-error notice shown via the same `.alert` channel — e.g.
    /// "No purchases to restore." after a benign restore call.
    var infoMessage: String?

    /// Currently selected tier in the paywall. Default = Weekly.
    var selectedTier: Tier = .weekly

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.unitlift", category: "StoreManager")
    @ObservationIgnored nonisolated(unsafe) private var transactionListener: Task<Void, Never>?
    @ObservationIgnored private var entitlementRefreshState = EntitlementRefreshState()

    // MARK: - Init

    init() {
        guard !ProcessInfo.processInfo.isSwiftUIPreview else { return }
        if let cached = UserDefaults.standard.string(forKey: Self.lastKnownEntitlementKey) {
            activeTier = Tier(rawValue: cached)
            isPurchased = activeTier != nil
            hasCheckedEntitlement = true
        }
        transactionListener = listenForTransactions()
        Task { await checkEntitlement() }
        Task { await releaseEntitlementGateAfterTimeout() }
    }

    /// Nonisolated for the same back-deploy-shim SIGABRT as
    /// `ActiveWorkoutViewModel.deinit` — see the comment there. Safe:
    /// `transactionListener` is `nonisolated(unsafe)` and `Task.cancel()`
    /// is thread-safe.
    nonisolated deinit {
        transactionListener?.cancel()
    }

    // MARK: - Accessors

    func product(for tier: Tier) -> Product? {
        products[tier.rawValue]
    }

    func eligibleFreeTrial(for tier: Tier) -> Product.SubscriptionOffer? {
        guard freeTrialEligibleProductIDs.contains(tier.rawValue),
              let offer = product(for: tier)?.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        return offer
    }

    var selectedProduct: Product? { product(for: selectedTier) }

    // MARK: - Load Products

    @MainActor
    func loadProducts(force: Bool = false) async {
        guard products.isEmpty || force else {
            hasAttemptedProductLoad = true
            return
        }
        isLoading = true
        defer {
            isLoading = false
            hasAttemptedProductLoad = true
        }

        do {
            let loaded = try await Product.products(for: Self.allProductIDs)
            let eligibleFreeTrials = await eligibleFreeTrialProductIDs(in: loaded)
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            freeTrialEligibleProductIDs = eligibleFreeTrials
            let selectableTiers = Self.requiredTiers + [Tier.lifetime]
            if selectedProduct == nil,
               let firstAvailableTier = selectableTiers.first(where: { product(for: $0) != nil }) {
                selectedTier = firstAvailableTier
            }
        } catch {
            freeTrialEligibleProductIDs = []
            logger.error("Failed to load products: \(error.localizedDescription)")
        }
    }

    private func eligibleFreeTrialProductIDs(in loaded: [Product]) async -> Set<String> {
        var eligibleIDs: Set<String> = []

        for product in loaded {
            guard let subscription = product.subscription,
                  subscription.introductoryOffer?.paymentMode == .freeTrial,
                  await subscription.isEligibleForIntroOffer else { continue }
            eligibleIDs.insert(product.id)
        }

        return eligibleIDs
    }

    // MARK: - Purchase

    @MainActor
    func purchase() async {
        await purchase(tier: selectedTier)
    }

    @MainActor
    func purchase(tier: Tier) async {
        guard let product = product(for: tier) else { return }
        guard !isLoading else { return }
        purchaseError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                if let tier = Tier(rawValue: transaction.productID) {
                    confirmEntitlement(tier)
                }
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                // Ask-to-buy / SCA / parental approval. The entitlement will
                // arrive via the transaction listener once the parent approves;
                // we don't need to surface anything here. Phase 2: revisit
                // with a "Pending approval" message if support requests it.
                break
            @unknown default:
                break
            }
        } catch {
            logger.error("Purchase failed: \(error.localizedDescription)")
            purchaseError = "Purchase failed. Try again in a moment."
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async {
        guard !isLoading else { return }
        purchaseError = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await checkEntitlement()
            if !isPurchased {
                infoMessage = "No purchases to restore."
            }
        } catch StoreKitError.userCancelled {
            // User dismissed the Apple ID sign-in prompt. Intentional back-out,
            // not an error — surfacing an alert here punishes the user for
            // declining to authenticate.
            return
        } catch StoreKitError.networkError(_) {
            logger.error("Restore failed: network error")
            purchaseError = "Couldn't reach the App Store. Check your connection and try again."
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            purchaseError = "Couldn't restore purchases. Try again in a moment."
        }
    }

    // MARK: - Entitlement Check

    @MainActor
    func checkEntitlement() async {
        let refreshRevision = entitlementRefreshState.beginRefresh()
        var entitlementTier: Tier?
        var sawAny = false
        for await result in Transaction.currentEntitlements {
            sawAny = true
            do {
                let transaction = try checkVerified(result)
                if let tier = Tier(rawValue: transaction.productID) {
                    entitlementTier = tier
                }
            } catch {
                let productID = result.unsafePayloadValue.productID
                logger.error("Entitlement skipped, failed verification: \(productID, privacy: .public) — \(error.localizedDescription, privacy: .public)")
            }
            if entitlementTier != nil { break }
        }
        if entitlementTier == nil {
            logger.info("Entitlement check: none active (any results: \(sawAny, privacy: .public))")
        }
        if let entitlementTier {
            confirmEntitlement(entitlementTier)
        } else if entitlementRefreshState.canApplyEmptyResult(from: refreshRevision) {
            clearEntitlement()
        } else {
            logger.info("Ignoring stale empty entitlement result because a newer transaction changed access.")
        }
        hasCheckedEntitlement = true
    }

    /// First-install fallback: no cached answer exists yet, so the launch gate
    /// is blocking on `checkEntitlement()`. If StoreKit hasn't answered within
    /// the timeout, release the gate unpurchased — the paywall (with Restore)
    /// is recoverable; an infinite spinner is not.
    private func releaseEntitlementGateAfterTimeout() async {
        try? await Task.sleep(for: Self.entitlementGateTimeout)
        if !hasCheckedEntitlement {
            logger.error("Entitlement check did not answer within \(Self.entitlementGateTimeout.components.seconds)s; releasing launch gate unpurchased.")
            hasCheckedEntitlement = true
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try await self.checkVerified(result)
                    if Self.allProductIDs.contains(transaction.productID) {
                        await transaction.finish()
                        if transaction.revocationDate != nil
                            || transaction.isUpgraded
                            || transaction.expirationDate.map({ $0 <= Date() }) == true {
                            // A refund or expiration is an authoritative access
                            // change. Re-derive from current entitlements in
                            // case another subscription tier remains active.
                            await self.recordAuthoritativeEntitlementChange()
                            await self.checkEntitlement()
                        } else if let tier = Tier(rawValue: transaction.productID) {
                            // A verified active transaction is itself the
                            // entitlement. Applying it directly avoids the
                            // StoreKit race where currentEntitlements briefly
                            // returns empty after an Xcode/device purchase.
                            await self.confirmEntitlement(tier)
                        }
                    }
                } catch {
                    let productID = result.unsafePayloadValue.productID
                    await self.logUnverifiedTransaction(productID: productID, error: error)
                }
            }
        }
    }

    // MARK: - Verification

    private func confirmEntitlement(_ tier: Tier) {
        entitlementRefreshState.recordAuthoritativeChange()
        activeTier = tier
        isPurchased = true
        UserDefaults.standard.set(tier.rawValue, forKey: Self.lastKnownEntitlementKey)
        logger.info("Entitlement active: \(tier.rawValue, privacy: .public)")
    }

    private func clearEntitlement() {
        entitlementRefreshState.recordAuthoritativeChange()
        activeTier = nil
        isPurchased = false
        UserDefaults.standard.set("", forKey: Self.lastKnownEntitlementKey)
        logger.info("Entitlement inactive.")
    }

    private func recordAuthoritativeEntitlementChange() {
        entitlementRefreshState.recordAuthoritativeChange()
    }

    private func checkVerified(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .unverified(_, let error):
            #if DEBUG
            // A local StoreKit configuration signs transactions with Xcode,
            // not the App Store. On physical devices that test certificate can
            // fail StoreKit's verification even though the local purchase
            // completed. Trust only that explicit Xcode test environment, and
            // compile this exception out of TestFlight/App Store builds.
            if result.unsafePayloadValue.environment == .xcode {
                logger.warning("Accepting Xcode StoreKit test transaction for \(result.unsafePayloadValue.productID, privacy: .public) in Debug build.")
                return result.unsafePayloadValue
            }
            #endif
            throw error
        case .verified(let value):
            return value
        }
    }

    private func logUnverifiedTransaction(productID: String, error: Error) {
        logger.error("Transaction update skipped, failed verification: \(productID, privacy: .public) — \(error.localizedDescription, privacy: .public)")
    }
}

private extension ProcessInfo {
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
