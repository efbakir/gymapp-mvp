//
//  StoreManager.swift
//  Unit
//
//  Handles StoreKit 2 product loading, purchasing, and restore
//  for the one-time lifetime unlock.
//

import StoreKit
import OSLog

@MainActor
@Observable
final class StoreManager {
    // MARK: - Product ID

    /// Readable from `Task.detached` transaction listener without crossing the main actor.
    nonisolated static let lifetimeProductID = "com.unit.lifetime"

    // MARK: - State

    var product: Product?
    var isLoading = false
    var isPurchased = false
    var purchaseError: String?

    private let logger = Logger(subsystem: "com.unit.app", category: "StoreManager")
    nonisolated(unsafe) private var transactionListener: Task<Void, Never>?

    // MARK: - Init

    init() {
        transactionListener = listenForTransactions()
        Task { await checkEntitlement() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Product

    @MainActor
    func loadProduct() async {
        guard product == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [Self.lifetimeProductID])
            product = products.first
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    @MainActor
    func purchase() async {
        guard let product else { return }
        purchaseError = nil

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
            purchaseError = "Something went wrong. Please try again."
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async {
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
               transaction.productID == Self.lifetimeProductID {
                isPurchased = true
                return
            }
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.lifetimeProductID {
                    await transaction.finish()
                    await self?.notePurchaseVerified()
                }
            }
        }
    }

    private func notePurchaseVerified() {
        isPurchased = true
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
