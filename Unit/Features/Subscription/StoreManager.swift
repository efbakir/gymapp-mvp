//
//  StoreManager.swift
//  Unit
//
//  Handles StoreKit 2 product loading, purchasing, and restore
//  for the three Unit Pro tiers: Monthly, Annual, Lifetime.
//  Pricing authority: docs/pricing.md.
//

import StoreKit
import OSLog

@MainActor
@Observable
final class StoreManager {
    // MARK: - Product IDs

    enum Tier: String, CaseIterable, Identifiable {
        case monthly = "com.unit.monthly"
        case annual = "com.unit.annual"
        case lifetime = "com.unit.lifetime"

        var id: String { rawValue }
    }

    nonisolated static let lifetimeProductID = Tier.lifetime.rawValue
    nonisolated static let annualProductID = Tier.annual.rawValue
    nonisolated static let monthlyProductID = Tier.monthly.rawValue

    nonisolated private static let allProductIDs: [String] = [
        Tier.monthly.rawValue,
        Tier.annual.rawValue,
        Tier.lifetime.rawValue
    ]

    // MARK: - State

    var products: [String: Product] = [:]
    var isLoading = false
    var isPurchased = false
    var purchaseError: String?

    /// Currently selected tier in the paywall. Default = Annual (recommended).
    var selectedTier: Tier = .annual

    private let logger = Logger(subsystem: "com.unit.app", category: "StoreManager")
    @ObservationIgnored nonisolated(unsafe) private var transactionListener: Task<Void, Never>?

    // MARK: - Init

    init() {
        guard !ProcessInfo.processInfo.isSwiftUIPreview else { return }
        transactionListener = listenForTransactions()
        Task { await checkEntitlement() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Accessors

    func product(for tier: Tier) -> Product? {
        products[tier.rawValue]
    }

    var selectedProduct: Product? { product(for: selectedTier) }

    // MARK: - Load Products

    @MainActor
    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await Product.products(for: Self.allProductIDs)
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
        }
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
                await transaction.finish()
                isPurchased = true
            case .userCancelled:
                break
            case .pending:
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
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await checkEntitlement()
        } catch {
            logger.error("Restore failed: \(error.localizedDescription)")
            purchaseError = "Could not restore purchases. Please try again."
        }
    }

    // MARK: - Entitlement Check

    @MainActor
    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.allProductIDs.contains(transaction.productID) {
                isPurchased = true
                return
            }
        }
    }

    private func notePurchaseVerified() {
        isPurchased = true
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   Self.allProductIDs.contains(transaction.productID) {
                    await transaction.finish()
                    await self?.notePurchaseVerified()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}

private extension ProcessInfo {
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
