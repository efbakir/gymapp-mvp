//
//  ProgramImporter.swift
//  Unit
//
//  Converts a ProgramTemplate into live SwiftData models: Split, DayTemplates,
//  and ensures referenced Exercises exist (creating new ones from
//  ExerciseCatalog metadata when needed).
//

import Foundation
import SwiftData

enum ProgramImporter {
    /// Creates a Split + DayTemplates for the program. Exercises referenced in
    /// the template are matched against existing rows (by name or alias) and
    /// created from ExerciseCatalog metadata when missing. Returns the new
    /// Split.
    @MainActor
    @discardableResult
    static func importProgram(
        _ template: ProgramTemplate,
        into context: ModelContext
    ) -> Split {
        let existingExercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        var exerciseByNormalizedName: [String: Exercise] = [:]
        for exercise in existingExercises {
            for signature in [exercise.displayName] + exercise.aliases {
                exerciseByNormalizedName[normalize(signature)] = exercise
            }
        }

        func resolveExercise(named name: String) -> Exercise {
            if let match = exerciseByNormalizedName[normalize(name)] {
                return match
            }
            let catalogEntry = ExerciseCatalog.lookup(name)
            let exercise = Exercise(
                displayName: catalogEntry?.displayName ?? name,
                aliases: catalogEntry?.aliases ?? [],
                isBodyweight: catalogEntry?.isBodyweight ?? false,
                muscleGroup: catalogEntry?.muscleGroup ?? .fullBody,
                equipment: catalogEntry?.equipment ?? .other
            )
            context.insert(exercise)
            for signature in [exercise.displayName] + exercise.aliases {
                exerciseByNormalizedName[normalize(signature)] = exercise
            }
            return exercise
        }

        let split = Split(name: template.name)
        context.insert(split)

        var dayTemplates: [DayTemplate] = []
        for day in template.days {
            let exerciseIds = day.items.map { resolveExercise(named: $0.exerciseName).id }
            let dayTemplate = DayTemplate(
                name: day.name,
                splitId: split.id,
                orderedExerciseIds: exerciseIds,
                scheduledWeekday: day.weekday ?? 0
            )
            context.insert(dayTemplate)
            dayTemplates.append(dayTemplate)
        }

        split.orderedTemplateIds = dayTemplates.map(\.id)

        try? context.save()
        return split
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
