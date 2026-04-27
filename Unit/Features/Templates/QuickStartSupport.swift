//
//  QuickStartSupport.swift
//  Unit
//
//  Freestyle (“Quick Start”) sessions are intentionally off the Today surface for v1;
//  shared helpers keep template + cleanup logic in one place.
//

import Foundation
import SwiftData

enum QuickStartSupport {
    /// Removes empty unreferenced "Quick Start" day templates left after aborted freestyle sessions.
    static func cleanupOrphanedTemplates(
        modelContext: ModelContext,
        templates: [DayTemplate],
        sessions: [WorkoutSession]
    ) {
        let referencedTemplateIds = Set(sessions.map(\.templateId))
        for template in templates where template.name == "Quick Start"
            && template.orderedExerciseIds.isEmpty
            && !referencedTemplateIds.contains(template.id) {
            modelContext.delete(template)
        }
        try? modelContext.save()
    }

    /// Creates a fresh empty template and an in-progress session (same behavior as legacy Today Quick Start).
    static func startEmptyWorkout(modelContext: ModelContext, activeSplit: Split?) {
        let template = DayTemplate(
            name: "Quick Start",
            splitId: activeSplit?.id,
            orderedExerciseIds: []
        )
        modelContext.insert(template)

        let session = WorkoutSession(
            date: Date(),
            templateId: template.id,
            isCompleted: false
        )
        modelContext.insert(session)
        try? modelContext.save()
    }
}
