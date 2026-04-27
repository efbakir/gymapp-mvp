//
//  OnboardingViewModel.swift
//  Unit
//
//  Transient onboarding state. No SwiftData @Model — all writes happen
//  atomically in commit() when the user taps "Create My Program".
//

import Foundation
import Observation
import SwiftData

// MARK: - Supporting Types

struct OnboardingExercise: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var targetSets: Int?
}

struct OnboardingBaseline {
    var weightKg: Double = 0
    var reps: Int = 8
}

struct ImportedProgramExercise: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var sets: Int?
    var reps: Int?
    var weightKg: Double?
}

struct ImportedProgramDay: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var exercises: [ImportedProgramExercise]
}

// MARK: - ViewModel

@Observable
final class OnboardingViewModel {

    // MARK: Path

    enum SetupPath { case build }
    var setupPath: SetupPath = .build

    enum ImportMethod {
        case photo
        case paste
        case manual
    }
    var importMethod: ImportMethod = .manual

    // MARK: Units

    /// "kg" or "lb". Written to AppStorage("unitSystem") after commit.
    var unitSystem: String = "kg"

    // MARK: Split

    var dayCount: Int = 3
    var dayNames: [String] = ["", "", ""]
    var dayExercises: [[OnboardingExercise]] = [[], [], []]

    // MARK: Baselines

    var baselines: [UUID: OnboardingBaseline] = [:]

    // MARK: Start Date

    enum StartOption { case today, nextMonday, custom }
    var startOption: StartOption = .today
    var customDate: Date = Date()

    // MARK: - Computed Helpers

    var startDate: Date {
        let cal = Calendar.current
        switch startOption {
        case .today:
            return cal.startOfDay(for: Date())
        case .nextMonday:
            let weekday = cal.component(.weekday, from: Date())
            let days = weekday == 2 ? 7 : (9 - weekday) % 7
            return cal.date(byAdding: .day, value: days, to: cal.startOfDay(for: Date())) ?? Date()
        case .custom:
            return cal.startOfDay(for: customDate)
        }
    }

    var weightUnitLabel: String { unitSystem }

    /// Display a kg value in the user's chosen unit.
    func displayWeight(_ kg: Double) -> Double {
        unitSystem == "lb" ? kg * 2.20462 : kg
    }

    /// Convert a user-entered display value back to kg for storage.
    func storeWeightKg(_ displayValue: Double) -> Double {
        unitSystem == "lb" ? displayValue / 2.20462 : displayValue
    }

    // MARK: - Day Management

    func updateDayCount(_ newCount: Int) {
        let count = max(2, min(6, newCount))
        dayCount = count
        while dayNames.count < count { dayNames.append("") }
        if dayNames.count > count { dayNames = Array(dayNames.prefix(count)) }
        while dayExercises.count < count { dayExercises.append([]) }
        if dayExercises.count > count { dayExercises = Array(dayExercises.prefix(count)) }
    }

    // MARK: - Sample Seeding

    func seedSampleData() {
        dayCount = 3
        dayNames = ["Push", "Pull", "Legs"]

        let pushExs: [OnboardingExercise] = [
            OnboardingExercise(name: "Bench Press", targetSets: 3),
            OnboardingExercise(name: "Overhead Press", targetSets: 3),
            OnboardingExercise(name: "Tricep Pushdown", targetSets: 3)
        ]
        let pullExs: [OnboardingExercise] = [
            OnboardingExercise(name: "Barbell Row", targetSets: 3),
            OnboardingExercise(name: "Lat Pulldown", targetSets: 3),
            OnboardingExercise(name: "Pull-up", targetSets: 3)
        ]
        let legsExs: [OnboardingExercise] = [
            OnboardingExercise(name: "Back Squat", targetSets: 3),
            OnboardingExercise(name: "Romanian Deadlift", targetSets: 3),
            OnboardingExercise(name: "Leg Press", targetSets: 3)
        ]
        dayExercises = [pushExs, pullExs, legsExs]

        // Intermediate baselines (stored in kg)
        let samples: [(OnboardingExercise, Double, Int)] = [
            (pushExs[0], 80, 8),
            (pushExs[1], 52.5, 8),
            (pushExs[2], 30, 12),
            (pullExs[0], 70, 8),
            (pullExs[1], 60, 10),
            (pullExs[2], 0, 8),
            (legsExs[0], 90, 5),
            (legsExs[1], 100, 8),
            (legsExs[2], 120, 10)
        ]
        for (ex, kg, reps) in samples {
            baselines[ex.id] = OnboardingBaseline(weightKg: kg, reps: reps)
        }
    }

    // MARK: - Validation

    var splitIsValid: Bool {
        dayNames.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var exercisesAreValid: Bool {
        dayExercises.allSatisfy { !$0.isEmpty }
    }

    var baselinesAreValid: Bool {
        for day in dayExercises {
            for ex in day {
                let b = baselines[ex.id]
                if (b?.reps ?? 0) < 1 { return false }
            }
        }
        return true
    }

    /// Indices of days that are missing at least one exercise baseline.
    var incompleteDayIndices: Set<Int> {
        var result = Set<Int>()
        for (i, day) in dayExercises.enumerated() {
            for ex in day {
                let b = baselines[ex.id]
                if (b?.reps ?? 0) < 1 { result.insert(i) }
            }
        }
        return result
    }

    // MARK: - Commit

    func commit(modelContext: ModelContext) throws {
        // 1. Resolve exercises (name lookup or create)
        var nameToExercise: [String: Exercise] = [:]
        let existing = (try? modelContext.fetch(FetchDescriptor<Exercise>())) ?? []
        for ex in existing { nameToExercise[ex.displayName.lowercased()] = ex }

        var exerciseMap: [UUID: Exercise] = [:]
        for day in dayExercises {
            for onbEx in day {
                let key = onbEx.name.trimmingCharacters(in: .whitespaces).lowercased()
                let isBodyweight = isBodyweightExercise(named: onbEx.name)
                if let match = nameToExercise[key] {
                    if isBodyweight && !match.isBodyweight {
                        match.isBodyweight = true
                    }
                    exerciseMap[onbEx.id] = match
                } else {
                    let ex = Exercise(
                        displayName: onbEx.name.trimmingCharacters(in: .whitespaces),
                        isBodyweight: isBodyweight
                    )
                    modelContext.insert(ex)
                    exerciseMap[onbEx.id] = ex
                    nameToExercise[key] = ex
                }
            }
        }

        // 2. Create Split
        let splitName = dayNames.joined(separator: " / ")
        let split = Split(name: splitName)
        modelContext.insert(split)

        // 3. Create DayTemplates
        var templateIds: [UUID] = []
        for (i, name) in dayNames.enumerated() {
            let exerciseIds = dayExercises[i].compactMap { exerciseMap[$0.id]?.id }
            let tmpl = DayTemplate(name: name, splitId: split.id, orderedExerciseIds: exerciseIds)
            modelContext.insert(tmpl)
            templateIds.append(tmpl.id)
        }
        split.orderedTemplateIds = templateIds

        try modelContext.save()
    }
}

extension OnboardingViewModel {
    func isBodyweightExercise(named exerciseName: String) -> Bool {
        let name = normalizedExerciseName(exerciseName)
        let bodyweightKeywords = [
            "pull up", "chin up", "push up", "dip", "plank", "hanging leg raise",
            "ab wheel rollout", "sit up", "crunch", "mountain climber", "burpee",
            "bodyweight squat"
        ]
        return bodyweightKeywords.contains { name.contains($0) }
    }

    func baselineIsValid(forDay dayIndex: Int) -> Bool {
        guard dayExercises.indices.contains(dayIndex) else { return false }
        return dayExercises[dayIndex].allSatisfy { (baselines[$0.id]?.reps ?? 0) > 0 }
    }

    func applyImportedProgram(_ days: [ImportedProgramDay]) {
        let sanitizedDays = days.filter { !$0.exercises.isEmpty }
        guard !sanitizedDays.isEmpty else { return }

        dayCount = min(6, max(1, sanitizedDays.count))
        dayNames = Array(sanitizedDays.prefix(dayCount).enumerated().map { index, day in
            let trimmed = day.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Workout \(index + 1)" : trimmed
        })

        dayExercises = Array(sanitizedDays.prefix(dayCount).map { day in
            day.exercises.map { exercise in
                OnboardingExercise(name: exercise.name, targetSets: exercise.sets)
            }
        })

        baselines = [:]
        for (dayIndex, day) in sanitizedDays.prefix(dayCount).enumerated() {
            for (exerciseIndex, exercise) in day.exercises.enumerated() {
                guard dayExercises.indices.contains(dayIndex),
                      dayExercises[dayIndex].indices.contains(exerciseIndex) else { continue }
                let onboardingExercise = dayExercises[dayIndex][exerciseIndex]
                baselines[onboardingExercise.id] = OnboardingBaseline(
                    weightKg: exercise.weightKg ?? 0,
                    reps: max(1, exercise.reps ?? 8)
                )
            }
        }
    }

    private func normalizedExerciseName(_ name: String) -> String {
        name
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
    }
}

// MARK: - Common Exercise Library (suggestions)

enum ExerciseLibrary {
    static let suggestions: [String] = [
        // Chest
        "Bench Press", "Incline Bench Press", "Decline Bench Press",
        "Close-Grip Bench Press", "Pin Press", "Floor Press",
        "Dumbbell Bench Press", "Incline Dumbbell Press", "Decline Dumbbell Press",
        "Dumbbell Floor Press", "Dumbbell Flye", "Incline Dumbbell Flye",
        "Cable Fly", "Cable Crossover", "Machine Chest Press", "Pec Deck",
        "Push-up", "Incline Push-up", "Decline Push-up", "Diamond Push-up",
        "Dip", "Bench Dip", "Dumbbell Pullover",
        // Shoulders
        "Overhead Press", "Push Press", "Behind-the-Neck Press",
        "Dumbbell Shoulder Press", "Arnold Press", "Machine Shoulder Press",
        "Landmine Press",
        "Lateral Raise", "Cable Lateral Raise", "Machine Lateral Raise",
        "Front Raise", "Cable Front Raise",
        "Rear Delt Fly", "Reverse Pec Deck", "Face Pull", "Upright Row",
        // Triceps
        "Tricep Pushdown", "Rope Pushdown", "Overhead Tricep Extension",
        "Skull Crusher", "Dumbbell Skull Crusher", "JM Press",
        "Tricep Kickback", "Cable Kickback",
        // Back
        "Pull-up", "Chin-up", "Neutral-Grip Pull-up", "Weighted Pull-up",
        "Barbell Row", "Pendlay Row", "Yates Row",
        "Dumbbell Row", "Chest-Supported Row", "Single-Arm Dumbbell Row",
        "T-Bar Row", "Meadows Row", "Seal Row",
        "Lat Pulldown", "Straight-Arm Pulldown", "Cable Row", "Seated Cable Row",
        "Inverted Row", "Rack Pull", "Shrug", "Dumbbell Shrug",
        // Biceps
        "Barbell Curl", "EZ-Bar Curl",
        "Dumbbell Curl", "Incline Dumbbell Curl", "Hammer Curl", "Concentration Curl",
        "Preacher Curl", "Spider Curl",
        "Cable Curl", "Cable Hammer Curl", "Reverse Curl",
        // Quads
        "Back Squat", "Front Squat", "High-Bar Squat", "Low-Bar Squat",
        "Box Squat", "Pause Squat",
        "Leg Press", "Hack Squat", "Pendulum Squat", "Belt Squat",
        "Goblet Squat", "Dumbbell Squat", "Smith Machine Squat",
        "Leg Extension", "Sissy Squat",
        "Bulgarian Split Squat", "Split Squat",
        "Lunge", "Reverse Lunge", "Walking Lunge", "Step-Up", "Pistol Squat",
        // Hamstrings & Glutes
        "Deadlift", "Sumo Deadlift", "Trap Bar Deadlift",
        "Deficit Deadlift", "Snatch-Grip Deadlift",
        "Romanian Deadlift", "Stiff-Leg Deadlift", "Dumbbell Romanian Deadlift",
        "Leg Curl", "Seated Leg Curl", "Lying Leg Curl", "Nordic Curl",
        "Good Morning",
        "Hip Thrust", "Barbell Hip Thrust", "Single-Leg Hip Thrust", "Glute Bridge",
        "Glute Kickback", "Glute-Ham Raise",
        "Back Extension", "45° Back Extension",
        // Calves
        "Standing Calf Raise", "Seated Calf Raise",
        "Donkey Calf Raise", "Leg Press Calf Raise",
        // Core
        "Plank", "Side Plank", "Ab Wheel Rollout",
        "Hanging Leg Raise", "Hanging Knee Raise", "Toes-to-Bar",
        "Cable Crunch", "Crunch", "Sit-up", "Decline Sit-up",
        "Russian Twist", "Pallof Press", "Cable Woodchop",
        "L-Sit", "Dead Bug", "Bird Dog", "V-Up",
        // Olympic & Power
        "Power Clean", "Hang Clean", "Clean and Jerk",
        "Snatch", "Hang Snatch", "Clean Pull", "Snatch Pull",
        "Kettlebell Swing", "Kettlebell Snatch", "Turkish Get-Up",
        // Carries & Functional
        "Farmer's Walk", "Suitcase Carry", "Overhead Carry",
        "Sled Push", "Sled Drag",
        "Landmine Row", "Landmine Squat"
    ]

    static func filtered(by query: String) -> [String] {
        guard !query.isEmpty else { return suggestions }
        let q = query.lowercased()
        return suggestions.filter { $0.lowercased().contains(q) }
    }
}
