//
//  FeedbackPortalConfigurationTests.swift
//  UnitTests
//

import XCTest
@testable import Unit

@MainActor
final class FeedbackPortalConfigurationTests: XCTestCase {
    func testFeatureRequestURLIsPrefilledSupportEmail() throws {
        let url = try XCTUnwrap(AppCopy.FeatureRequest.requestURL)
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.scheme, "mailto")
        XCTAssertEqual(components.path, "support@unitlift.app")
        XCTAssertEqual(
            components.queryItems?.first(where: { $0.name == "subject" })?.value,
            "Unit feature request"
        )
        XCTAssertTrue(
            components.queryItems?.first(where: { $0.name == "body" })?.value?
                .contains("What problem would this solve?") == true
        )
    }

    func testActionTitleRemainsExplicit() {
        XCTAssertEqual(
            AppCopy.FeatureRequest.actionTitle,
            "Request a feature"
        )
    }

    func testUpdatesURLUsesCanonicalHTTPSDestination() throws {
        let url = try XCTUnwrap(AppCopy.Updates.url)
        XCTAssertEqual(url.absoluteString, "https://unitlift.app/updates")
    }
}
