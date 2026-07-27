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
