//
//  FeedbackPortalConfigurationTests.swift
//  UnitTests
//

import XCTest
@testable import Unit

@MainActor
final class FeedbackPortalConfigurationTests: XCTestCase {
    func testPortalURLIsParameterFreeFeaturebaseHTTPSDestination() throws {
        let url = try XCTUnwrap(AppCopy.FeatureRequest.portalURL)
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.scheme, "https")
        XCTAssertTrue(
            components.host?.lowercased().hasSuffix(".featurebase.app") == true
        )
        XCTAssertNil(components.user)
        XCTAssertNil(components.password)
        XCTAssertNil(components.query)
        XCTAssertNil(components.fragment)
    }

    func testActionTitleRemainsExplicit() {
        XCTAssertEqual(
            AppCopy.FeatureRequest.actionTitle,
            "Request a feature"
        )
    }
}
