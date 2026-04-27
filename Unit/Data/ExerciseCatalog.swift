//
//  ExerciseCatalog.swift
//  Unit
//
//  Structured catalog of seed exercises. Used by UnitApp to populate the
//  SwiftData store on first launch and by ProgramImporter to resolve
//  program templates to real Exercise models.
//

import Foundation

struct CatalogExercise {
    let displayName: String
    let aliases: [String]
    let isBodyweight: Bool
    let muscleGroup: MuscleGroup
    let equipment: Equipment
}

enum ExerciseCatalog {
    static let all: [CatalogExercise] = [
        // MARK: Chest
        .init(displayName: "Bench Press", aliases: ["Bench Press (BB)", "Barbell Bench"], isBodyweight: false, muscleGroup: .chest, equipment: .barbell),
        .init(displayName: "Incline Bench Press", aliases: ["Incline BB Bench"], isBodyweight: false, muscleGroup: .chest, equipment: .barbell),
        .init(displayName: "Close-Grip Bench", aliases: ["Close Grip Bench Press"], isBodyweight: false, muscleGroup: .chest, equipment: .barbell),
        .init(displayName: "DB Bench Press", aliases: ["Dumbbell Bench Press"], isBodyweight: false, muscleGroup: .chest, equipment: .dumbbell),
        .init(displayName: "Incline DB Press", aliases: ["Incline DB Bench"], isBodyweight: false, muscleGroup: .chest, equipment: .dumbbell),
        .init(displayName: "DB Fly", aliases: ["Dumbbell Fly"], isBodyweight: false, muscleGroup: .chest, equipment: .dumbbell),
        .init(displayName: "Chest Press Machine", aliases: ["Machine Chest Press"], isBodyweight: false, muscleGroup: .chest, equipment: .machine),
        .init(displayName: "Pec Dec", aliases: ["Pec Deck", "Pectec"], isBodyweight: false, muscleGroup: .chest, equipment: .machine),
        .init(displayName: "Cable Crossover", aliases: ["Cable Fly"], isBodyweight: false, muscleGroup: .chest, equipment: .cable),
        .init(displayName: "Push-Up", aliases: ["Pushup"], isBodyweight: true, muscleGroup: .chest, equipment: .bodyweight),
        .init(displayName: "Weighted Dips", aliases: ["Dips"], isBodyweight: false, muscleGroup: .chest, equipment: .bodyweight),

        // MARK: Back
        .init(displayName: "Deadlift (Conv)", aliases: ["Conventional Deadlift", "Deadlift"], isBodyweight: false, muscleGroup: .back, equipment: .barbell),
        .init(displayName: "Bent Over Row (BB)", aliases: ["Barbell Row"], isBodyweight: false, muscleGroup: .back, equipment: .barbell),
        .init(displayName: "Pendlay Row", aliases: [], isBodyweight: false, muscleGroup: .back, equipment: .barbell),
        .init(displayName: "T-Bar Row", aliases: [], isBodyweight: false, muscleGroup: .back, equipment: .barbell),
        .init(displayName: "Single-Arm DB Row", aliases: ["One-Arm DB Row", "DB Row"], isBodyweight: false, muscleGroup: .back, equipment: .dumbbell),
        .init(displayName: "Lat Pulldown", aliases: [], isBodyweight: false, muscleGroup: .back, equipment: .cable),
        .init(displayName: "Seated Cable Row", aliases: ["Cable Row"], isBodyweight: false, muscleGroup: .back, equipment: .cable),
        .init(displayName: "Chest-Supported Row", aliases: ["Machine Row"], isBodyweight: false, muscleGroup: .back, equipment: .machine),
        .init(displayName: "Pull-Up", aliases: ["Pullup"], isBodyweight: true, muscleGroup: .back, equipment: .bodyweight),
        .init(displayName: "Weighted Pull-Up", aliases: [], isBodyweight: false, muscleGroup: .back, equipment: .bodyweight),
        .init(displayName: "Chin-Up", aliases: ["Chinup"], isBodyweight: true, muscleGroup: .back, equipment: .bodyweight),
        .init(displayName: "Face Pull", aliases: [], isBodyweight: false, muscleGroup: .back, equipment: .cable),

        // MARK: Shoulders
        .init(displayName: "OHP (BB)", aliases: ["Overhead Press", "OHP", "Military Press"], isBodyweight: false, muscleGroup: .shoulders, equipment: .barbell),
        .init(displayName: "Push Press", aliases: [], isBodyweight: false, muscleGroup: .shoulders, equipment: .barbell),
        .init(displayName: "DB Shoulder Press", aliases: ["DB Press", "Seated DB Press"], isBodyweight: false, muscleGroup: .shoulders, equipment: .dumbbell),
        .init(displayName: "Single-Arm DB Press", aliases: ["One-Arm DB Press"], isBodyweight: false, muscleGroup: .shoulders, equipment: .dumbbell),
        .init(displayName: "Lateral Raise (DB)", aliases: ["Lateral Raise", "Side Raise"], isBodyweight: false, muscleGroup: .shoulders, equipment: .dumbbell),
        .init(displayName: "Rear Delt Fly", aliases: ["Reverse Fly"], isBodyweight: false, muscleGroup: .shoulders, equipment: .dumbbell),
        .init(displayName: "Cable Lateral Raise", aliases: [], isBodyweight: false, muscleGroup: .shoulders, equipment: .cable),
        .init(displayName: "Shrug (DB)", aliases: ["DB Shrug"], isBodyweight: false, muscleGroup: .shoulders, equipment: .dumbbell),

        // MARK: Biceps
        .init(displayName: "Barbell Curl", aliases: ["BB Curl"], isBodyweight: false, muscleGroup: .biceps, equipment: .barbell),
        .init(displayName: "DB Curl", aliases: ["Curl", "Biceps Curl", "Dumbbell Curl"], isBodyweight: false, muscleGroup: .biceps, equipment: .dumbbell),
        .init(displayName: "Hammer Curl", aliases: [], isBodyweight: false, muscleGroup: .biceps, equipment: .dumbbell),
        .init(displayName: "Preacher Curl", aliases: [], isBodyweight: false, muscleGroup: .biceps, equipment: .machine),
        .init(displayName: "Cable Curl", aliases: [], isBodyweight: false, muscleGroup: .biceps, equipment: .cable),

        // MARK: Triceps
        .init(displayName: "Triceps Extension", aliases: ["Triceps", "Overhead Triceps Extension"], isBodyweight: false, muscleGroup: .triceps, equipment: .dumbbell),
        .init(displayName: "Triceps Pushdown", aliases: ["Cable Pushdown"], isBodyweight: false, muscleGroup: .triceps, equipment: .cable),
        .init(displayName: "Skullcrusher", aliases: ["Lying Triceps Extension"], isBodyweight: false, muscleGroup: .triceps, equipment: .barbell),
        .init(displayName: "Triceps Dip", aliases: ["Bench Dip"], isBodyweight: true, muscleGroup: .triceps, equipment: .bodyweight),

        // MARK: Quads
        .init(displayName: "Back Squat (BB)", aliases: ["Back Squat", "Squat"], isBodyweight: false, muscleGroup: .quads, equipment: .barbell),
        .init(displayName: "Front Squat", aliases: [], isBodyweight: false, muscleGroup: .quads, equipment: .barbell),
        .init(displayName: "Goblet Squat", aliases: [], isBodyweight: false, muscleGroup: .quads, equipment: .dumbbell),
        .init(displayName: "Leg Press", aliases: [], isBodyweight: false, muscleGroup: .quads, equipment: .machine),
        .init(displayName: "Leg Extension", aliases: [], isBodyweight: false, muscleGroup: .quads, equipment: .machine),
        .init(displayName: "Bulgarian Split Squat", aliases: ["Split Squat"], isBodyweight: false, muscleGroup: .quads, equipment: .dumbbell),
        .init(displayName: "Walking Lunge", aliases: ["Lunge"], isBodyweight: false, muscleGroup: .quads, equipment: .dumbbell),
        .init(displayName: "Step-Up", aliases: [], isBodyweight: false, muscleGroup: .quads, equipment: .dumbbell),

        // MARK: Hamstrings
        .init(displayName: "Romanian DL", aliases: ["Romanian Deadlift", "RDL"], isBodyweight: false, muscleGroup: .hamstrings, equipment: .barbell),
        .init(displayName: "DB Romanian DL", aliases: ["DB RDL"], isBodyweight: false, muscleGroup: .hamstrings, equipment: .dumbbell),
        .init(displayName: "Hamstring Curl", aliases: ["Leg Curl", "Seated Leg Curl"], isBodyweight: false, muscleGroup: .hamstrings, equipment: .machine),
        .init(displayName: "Nordic Curl", aliases: [], isBodyweight: true, muscleGroup: .hamstrings, equipment: .bodyweight),
        .init(displayName: "Good Morning", aliases: [], isBodyweight: false, muscleGroup: .hamstrings, equipment: .barbell),

        // MARK: Glutes
        .init(displayName: "Hip Thrust", aliases: ["Barbell Hip Thrust"], isBodyweight: false, muscleGroup: .glutes, equipment: .barbell),
        .init(displayName: "Glute Bridge", aliases: [], isBodyweight: true, muscleGroup: .glutes, equipment: .bodyweight),
        .init(displayName: "Cable Kickback", aliases: [], isBodyweight: false, muscleGroup: .glutes, equipment: .cable),
        .init(displayName: "Glute Ham Raise", aliases: ["GHR"], isBodyweight: true, muscleGroup: .glutes, equipment: .bodyweight),

        // MARK: Calves
        .init(displayName: "Standing Calf Raise", aliases: ["Calf Raise"], isBodyweight: false, muscleGroup: .calves, equipment: .machine),
        .init(displayName: "Seated Calf Raise", aliases: [], isBodyweight: false, muscleGroup: .calves, equipment: .machine),
        .init(displayName: "DB Calf Raise", aliases: [], isBodyweight: false, muscleGroup: .calves, equipment: .dumbbell),

        // MARK: Core
        .init(displayName: "Plank", aliases: [], isBodyweight: true, muscleGroup: .core, equipment: .bodyweight),
        .init(displayName: "Hanging Leg Raise", aliases: ["Leg Raise"], isBodyweight: true, muscleGroup: .core, equipment: .bodyweight),
        .init(displayName: "Cable Crunch", aliases: [], isBodyweight: false, muscleGroup: .core, equipment: .cable),
        .init(displayName: "Pallof Press", aliases: [], isBodyweight: false, muscleGroup: .core, equipment: .cable),
        .init(displayName: "Ab Wheel", aliases: ["Ab Rollout"], isBodyweight: true, muscleGroup: .core, equipment: .other),

        // MARK: Forearms
        .init(displayName: "Wrist Curl", aliases: [], isBodyweight: false, muscleGroup: .forearms, equipment: .dumbbell),
        .init(displayName: "Reverse Curl", aliases: [], isBodyweight: false, muscleGroup: .forearms, equipment: .barbell),

        // MARK: Full body / conditioning
        .init(displayName: "Kettlebell Swing", aliases: ["KB Swing"], isBodyweight: false, muscleGroup: .fullBody, equipment: .kettlebell),
        .init(displayName: "DB Snatch", aliases: [], isBodyweight: false, muscleGroup: .fullBody, equipment: .dumbbell),
        .init(displayName: "Clean & Press", aliases: [], isBodyweight: false, muscleGroup: .fullBody, equipment: .barbell),
        .init(displayName: "Broad Jump", aliases: [], isBodyweight: true, muscleGroup: .fullBody, equipment: .bodyweight),
        .init(displayName: "Box Jump", aliases: [], isBodyweight: true, muscleGroup: .fullBody, equipment: .bodyweight)
    ]

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }

    /// Look up a catalog entry by name or alias (case/diacritic-insensitive).
    static func lookup(_ name: String) -> CatalogExercise? {
        let needle = normalize(name)
        return all.first { entry in
            if normalize(entry.displayName) == needle { return true }
            return entry.aliases.contains { normalize($0) == needle }
        }
    }
}
