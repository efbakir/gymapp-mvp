//
//  EngagementPromptTrackerTests.swift
//  UnitTests
//

import XCTest
@testable import Unit

@MainActor
final class EngagementPromptTrackerTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "EngagementPromptTrackerTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDuplicateSessionIDsDoNotAdvanceCompletedWorkoutCount() {
        let tracker = EngagementPromptTracker(defaults: defaults)
        let first = UUID()

        XCTAssertEqual(tracker.recordCompletedWorkout(sessionID: first), 1)
        XCTAssertEqual(tracker.recordCompletedWorkout(sessionID: first), 1)
        XCTAssertEqual(tracker.completedWorkoutCount, 1)
    }

    func testReviewEligibilityBeginsAfterThreeDistinctCompletedWorkouts() {
        let tracker = EngagementPromptTracker(defaults: defaults)
        XCTAssertFalse(tracker.shouldRequestReview)

        tracker.recordCompletedWorkout(sessionID: UUID())
        XCTAssertFalse(tracker.shouldRequestReview)

        tracker.recordCompletedWorkout(sessionID: UUID())
        XCTAssertFalse(tracker.shouldRequestReview)

        tracker.recordCompletedWorkout(sessionID: UUID())
        XCTAssertTrue(tracker.shouldRequestReview)
    }

    func testReviewAttemptPersistsAcrossTrackerInstances() {
        let tracker = EngagementPromptTracker(defaults: defaults)
        tracker.recordCompletedWorkout(sessionID: UUID())
        tracker.recordCompletedWorkout(sessionID: UUID())
        tracker.recordCompletedWorkout(sessionID: UUID())

        let reloadedTracker = EngagementPromptTracker(defaults: defaults)
        XCTAssertTrue(reloadedTracker.shouldRequestReview)

        reloadedTracker.markReviewRequestAttempted()
        XCTAssertFalse(EngagementPromptTracker(defaults: defaults).shouldRequestReview)
        XCTAssertTrue(EngagementPromptTracker(defaults: defaults).reviewRequestAttempted)
    }
}
