//
//  EntitlementRefreshStateTests.swift
//  UnitTests
//

import XCTest
@testable import Unit

@MainActor
final class EntitlementRefreshStateTests: XCTestCase {
    func testEmptyRefreshThatStartedBeforePurchaseIsIgnored() {
        var state = EntitlementRefreshState()
        let refreshRevision = state.beginRefresh()

        state.recordAuthoritativeChange()

        XCTAssertFalse(state.canApplyEmptyResult(from: refreshRevision))
    }

    func testFreshEmptyRefreshCanRevokeEntitlement() {
        var state = EntitlementRefreshState()
        state.recordAuthoritativeChange()
        let refreshRevision = state.beginRefresh()

        XCTAssertTrue(state.canApplyEmptyResult(from: refreshRevision))
    }

    func testSecondAuthoritativeChangeInvalidatesExistingRefresh() {
        var state = EntitlementRefreshState()
        state.recordAuthoritativeChange()
        let refreshRevision = state.beginRefresh()

        state.recordAuthoritativeChange()

        XCTAssertFalse(state.canApplyEmptyResult(from: refreshRevision))
    }
}

@MainActor
final class StorePlanPresentationTests: XCTestCase {
    func testEligibleMonthlyShowsConfiguredFreeTrial() {
        let presentation = resolve(
            snapshot: subscriptionSnapshot(renewalUnit: .month),
            eligible: true
        )

        XCTAssertEqual(presentation.trial?.durationText, "7 days")
        XCTAssertEqual(presentation.trial?.adjectiveText, "7-day")
    }

    func testEligibleYearlyShowsConfiguredFreeTrial() {
        let presentation = resolve(
            snapshot: subscriptionSnapshot(
                displayPrice: "$29.99",
                renewalUnit: .year
            ),
            eligible: true
        )

        XCTAssertEqual(presentation.trial?.durationText, "7 days")
        XCTAssertEqual(presentation.billingPeriodText, "year")
    }

    func testWeeklyWithoutOfferNeverShowsTrial() {
        let snapshot = StoreProductSnapshot(
            isAutoRenewable: true,
            displayPrice: "$2.99",
            renewalPeriod: .init(unit: .week, value: 1),
            introductoryOffer: nil
        )

        XCTAssertNil(resolve(snapshot: snapshot, eligible: true).trial)
    }

    func testLifetimeNeverShowsTrialEvenWithOfferAndEligibility() {
        let snapshot = StoreProductSnapshot(
            isAutoRenewable: false,
            displayPrice: "$44.99",
            renewalPeriod: nil,
            introductoryOffer: freeWeekOffer
        )

        let presentation = resolve(snapshot: snapshot, eligible: true)
        XCTAssertNil(presentation.trial)
        XCTAssertEqual(presentation.billedPriceText, "$44.99")
    }

    func testIneligibleMonthlyAndYearlyDoNotShowTrial() {
        let monthly = resolve(
            snapshot: subscriptionSnapshot(renewalUnit: .month),
            eligible: false
        )
        let yearly = resolve(
            snapshot: subscriptionSnapshot(renewalUnit: .year),
            eligible: false
        )

        XCTAssertNil(monthly.trial)
        XCTAssertNil(yearly.trial)
    }

    func testEligibilityWithoutConfiguredOfferDoesNotCreateTrial() {
        let snapshot = StoreProductSnapshot(
            isAutoRenewable: true,
            displayPrice: "$4.99",
            renewalPeriod: .init(unit: .month, value: 1),
            introductoryOffer: nil
        )

        XCTAssertNil(resolve(snapshot: snapshot, eligible: true).trial)
    }

    func testNonFreeIntroductoryOfferDoesNotCreateTrial() {
        let snapshot = subscriptionSnapshot(
            renewalUnit: .month,
            offerMode: .payUpFront
        )

        XCTAssertNil(resolve(snapshot: snapshot, eligible: true).trial)
    }

    func testTrialDurationPriceAndRenewalPeriodAreDerivedFromSnapshot() {
        let snapshot = subscriptionSnapshot(
            displayPrice: "₺199,99",
            renewalUnit: .month
        )

        let presentation = resolve(snapshot: snapshot, eligible: true)

        XCTAssertEqual(presentation.trial?.durationText, "7 days")
        XCTAssertEqual(presentation.displayPrice, "₺199,99")
        XCTAssertEqual(presentation.billingPeriodText, "month")
        XCTAssertEqual(presentation.billedPriceText, "₺199,99/month")
    }

    func testInvalidTrialDurationDoesNotCreateTrial() {
        let snapshot = StoreProductSnapshot(
            isAutoRenewable: true,
            displayPrice: "$4.99",
            renewalPeriod: .init(unit: .month, value: 1),
            introductoryOffer: .init(
                paymentMode: .freeTrial,
                period: .init(unit: .week, value: 0),
                periodCount: 1
            )
        )

        XCTAssertNil(resolve(snapshot: snapshot, eligible: true).trial)
    }

    private var freeWeekOffer: StoreIntroductoryOfferSnapshot {
        .init(
            paymentMode: .freeTrial,
            period: .init(unit: .week, value: 1),
            periodCount: 1
        )
    }

    private func subscriptionSnapshot(
        displayPrice: String = "$4.99",
        renewalUnit: StoreSubscriptionPeriodSnapshot.Unit,
        offerMode: StoreIntroductoryOfferSnapshot.PaymentMode = .freeTrial
    ) -> StoreProductSnapshot {
        StoreProductSnapshot(
            isAutoRenewable: true,
            displayPrice: displayPrice,
            renewalPeriod: .init(unit: renewalUnit, value: 1),
            introductoryOffer: .init(
                paymentMode: offerMode,
                period: .init(unit: .week, value: 1),
                periodCount: 1
            )
        )
    }

    private func resolve(
        snapshot: StoreProductSnapshot,
        eligible: Bool
    ) -> StorePlanPresentation {
        StorePlanPresentation.resolve(
            snapshot: snapshot,
            isEligibleForIntroOffer: eligible
        )
    }
}

@MainActor
final class PaywallPlanSelectionStateTests: XCTestCase {
    func testEligibleNewCustomerDefaultsToMonthly() {
        var selection = PaywallPlanSelectionState()

        selection.applyInitialDefault(
            availableTiers: [.weekly, .monthly, .annual],
            monthlyHasEligibleTrial: true
        )

        XCTAssertEqual(selection.selectedTier, .monthly)
    }

    func testIneligibleCustomerKeepsWeeklyDefault() {
        var selection = PaywallPlanSelectionState()

        selection.applyInitialDefault(
            availableTiers: [.weekly, .monthly, .annual],
            monthlyHasEligibleTrial: false
        )

        XCTAssertEqual(selection.selectedTier, .weekly)
    }

    func testAsyncEligibilityCannotOverrideUserSelection() {
        var selection = PaywallPlanSelectionState()
        selection.selectByUser(.annual)

        selection.applyInitialDefault(
            availableTiers: [.weekly, .monthly, .annual],
            monthlyHasEligibleTrial: true
        )

        XCTAssertEqual(selection.selectedTier, .annual)
        XCTAssertTrue(selection.hasUserSelectedTier)
    }

    func testPartialLoadFallsBackToFirstAvailableRequiredTier() {
        var selection = PaywallPlanSelectionState()

        selection.applyInitialDefault(
            availableTiers: [.annual],
            monthlyHasEligibleTrial: false
        )

        XCTAssertEqual(selection.selectedTier, .annual)
    }
}

@MainActor
final class PurchaseAttemptStateTests: XCTestCase {
    func testRepeatedTapCannotStartDuplicatePurchase() {
        var state = PurchaseAttemptState()

        XCTAssertTrue(state.begin())
        XCTAssertFalse(state.begin())
        XCTAssertTrue(state.isPurchasing)
    }

    func testPendingPurchaseBlocksRetriesUntilVerifiedUpdateFinishesIt() {
        var state = PurchaseAttemptState()
        XCTAssertTrue(state.begin())

        state.markPending()

        XCTAssertTrue(state.isPending)
        XCTAssertTrue(state.blocksNewAttempt)
        XCTAssertFalse(state.begin())

        state.finish()

        XCTAssertFalse(state.blocksNewAttempt)
        XCTAssertTrue(state.begin())
    }

    func testCancelledOrUnverifiedPurchaseCanReturnToIdle() {
        var state = PurchaseAttemptState()
        XCTAssertTrue(state.begin())

        state.finish()

        XCTAssertEqual(state.phase, .idle)
        XCTAssertTrue(state.begin())
    }
}
