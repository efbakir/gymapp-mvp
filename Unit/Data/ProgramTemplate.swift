//
//  ProgramTemplate.swift
//  Unit
//
//  Value types describing a pre-built program that can be imported into the
//  user's library (Split + DayTemplates + Exercises). These are static
//  catalog data — not SwiftData models.
//

import Foundation

struct ProgramTemplate: Identifiable, Hashable {
    enum Level: String, CaseIterable, Identifiable {
        case beginner, intermediate, advanced
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
    }

    enum Goal: String, CaseIterable, Identifiable {
        case strength, hypertrophy, mixed
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .strength: return "Strength"
            case .hypertrophy: return "Hypertrophy"
            case .mixed: return "Mixed"
            }
        }
    }

    let id: UUID
    let name: String
    let level: Level
    let goal: Goal
    let daysPerWeek: Int
    let summary: String
    let description: String
    let days: [ProgramDay]
}

struct ProgramDay: Identifiable, Hashable {
    let id: UUID
    let name: String
    /// 1–7 (Sun–Sat); optional — omit for non-calendar-bound programs.
    let weekday: Int?
    let items: [ProgramItem]
}

struct ProgramItem: Identifiable, Hashable {
    let id: UUID
    let exerciseName: String
    let setCount: Int
    let repTarget: Int
    let notes: String?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        setCount: Int,
        repTarget: Int,
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setCount = setCount
        self.repTarget = repTarget
        self.notes = notes
    }
}
