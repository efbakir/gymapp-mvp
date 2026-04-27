//
//  DayTemplate.swift
//  Unit
//
//  SwiftData models: split and program day with ordered exercise IDs.
//

import Foundation
import SwiftData

@Model
final class Split {
    var id: UUID
    var name: String
    var orderedTemplateIdsData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        orderedTemplateIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.orderedTemplateIdsData = (try? JSONEncoder().encode(orderedTemplateIds.map { $0.uuidString })) ?? nil
    }

    var orderedTemplateIds: [UUID] {
        get {
            guard let data = orderedTemplateIdsData,
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded.compactMap { UUID(uuidString: $0) }
        }
        set {
            orderedTemplateIdsData = try? JSONEncoder().encode(newValue.map { $0.uuidString })
        }
    }
}

/// UserDefaults-backed pointer to the user's currently active `Split`.
/// Fallback: first split by name (legacy behavior) when nothing is set.
/// Views that need reactivity should bind `@AppStorage("activeSplitId")` so
/// SwiftUI re-evaluates when the user switches programs.
enum ActiveSplitStore {
    static let defaultsKey = "activeSplitId"

    static func currentId() -> UUID? {
        guard let raw = UserDefaults.standard.string(forKey: defaultsKey),
              let uuid = UUID(uuidString: raw) else { return nil }
        return uuid
    }

    static func setCurrent(_ id: UUID?) {
        if let id {
            UserDefaults.standard.set(id.uuidString, forKey: defaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: defaultsKey)
        }
    }

    static func resolve(from splits: [Split]) -> Split? {
        if let id = currentId(), let match = splits.first(where: { $0.id == id }) {
            return match
        }
        return splits.first
    }
}

@Model
final class DayTemplate {
    var id: UUID
    var name: String
    var splitId: UUID?
    var orderedExerciseIdsData: Data?
    var lastPerformedDate: Date?
    /// Calendar weekday: 1=Sun, 2=Mon … 7=Sat.  0 = unscheduled (rotation mode).
    var scheduledWeekday: Int = 0

    init(
        id: UUID = UUID(),
        name: String,
        splitId: UUID? = nil,
        orderedExerciseIds: [UUID] = [],
        lastPerformedDate: Date? = nil,
        scheduledWeekday: Int = 0
    ) {
        self.id = id
        self.name = name
        self.splitId = splitId
        self.orderedExerciseIdsData = (try? JSONEncoder().encode(orderedExerciseIds.map { $0.uuidString })) ?? nil
        self.lastPerformedDate = lastPerformedDate
        self.scheduledWeekday = scheduledWeekday
    }

    /// Strips "Day N · " prefix if present, returning just the routine name.
    var displayName: String {
        let pattern = /^Day\s+\d+\s*·\s*/
        let stripped = name.replacing(pattern, with: "")
        return stripped.isEmpty ? name : stripped
    }

    var orderedExerciseIds: [UUID] {
        get {
            guard let data = orderedExerciseIdsData,
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded.compactMap { UUID(uuidString: $0) }
        }
        set {
            orderedExerciseIdsData = try? JSONEncoder().encode(newValue.map { $0.uuidString })
        }
    }
}
