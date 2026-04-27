//
//  SetEntry.swift
//  Unit
//
//  SwiftData model: one set (weight, reps, RPE, warmup, completed).
//

import Foundation
import SwiftData

@Model
final class SetEntry {
    var id: UUID
    var sessionId: UUID
    var exerciseId: UUID
    var weight: Double
    var reps: Int
    /// 1–10; 0 = not set. Kept for legacy data.
    var rpe: Double
    /// Reps In Reserve: 0–5; -1 = not set.
    var rir: Int
    var isWarmup: Bool
    var isCompleted: Bool
    var setIndex: Int
    var note: String

    @Relationship(inverse: \WorkoutSession.setEntries)
    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        exerciseId: UUID,
        weight: Double = 0,
        reps: Int = 0,
        rpe: Double = 0,
        rir: Int = -1,
        isWarmup: Bool = false,
        isCompleted: Bool = false,
        setIndex: Int = 0,
        note: String = ""
    ) {
        self.id = id
        self.sessionId = sessionId
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.rir = rir
        self.isWarmup = isWarmup
        self.isCompleted = isCompleted
        self.setIndex = setIndex
        self.note = note
    }
}
