//
//  EngagementPromptTracker.swift
//  Unit
//
//  Version-scoped, local-only StoreKit review state.
//

import Foundation

struct EngagementPromptTracker {
    private static let reviewEligibilityWorkoutCount = 3

    private enum Key {
        static let completedSessionIDs = "engagement.v2_1.completedSessionIDs"
        static let reviewRequestAttempted = "engagement.v2_1.reviewRequestAttempted"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var completedWorkoutCount: Int {
        completedSessionIDs.count
    }

    var shouldRequestReview: Bool {
        completedWorkoutCount >= Self.reviewEligibilityWorkoutCount
            && !reviewRequestAttempted
    }

    var reviewRequestAttempted: Bool {
        defaults.bool(forKey: Key.reviewRequestAttempted)
    }

    @discardableResult
    func recordCompletedWorkout(sessionID: UUID) -> Int {
        var ids = completedSessionIDs
        let value = sessionID.uuidString

        guard !ids.contains(value),
              ids.count < Self.reviewEligibilityWorkoutCount else {
            return ids.count
        }

        ids.append(value)
        defaults.set(ids, forKey: Key.completedSessionIDs)
        return ids.count
    }

    func markReviewRequestAttempted() {
        defaults.set(true, forKey: Key.reviewRequestAttempted)
    }

    static func seedCompletedWorkoutCountForUITesting(
        _ count: Int,
        defaults: UserDefaults = .standard
    ) {
        let safeCount = min(max(count, 0), reviewEligibilityWorkoutCount)
        let ids = (0..<safeCount).map { _ in UUID().uuidString }
        defaults.set(ids, forKey: Key.completedSessionIDs)
    }

    private var completedSessionIDs: [String] {
        let values = defaults.stringArray(forKey: Key.completedSessionIDs) ?? []
        return Array(values.prefix(Self.reviewEligibilityWorkoutCount))
    }
}
