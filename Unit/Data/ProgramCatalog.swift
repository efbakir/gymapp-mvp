//
//  ProgramCatalog.swift
//  Unit
//
//  Eight curated starter programs. Each program references exercises from
//  ExerciseCatalog by displayName/alias — ProgramImporter resolves these to
//  real Exercise models on import.
//

import Foundation

enum ProgramCatalog {
    static let all: [ProgramTemplate] = [
        startingStrength,
        gzclp,
        strongCurves,
        upperLower4Day,
        fiveThreeOneBBB,
        metallicadpaPPL,
        dumbbellPPL,
        arnoldSplit
    ]

    // MARK: - 1. Starting Strength (Beginner, Strength, 3 days)
    private static let startingStrength = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Starting Strength",
        level: .beginner,
        goal: .strength,
        daysPerWeek: 3,
        summary: "Three-lift barbell novice program alternating A and B days.",
        description: "Mark Rippetoe's classic novice protocol. Train 3 days a week, alternating between Workout A and Workout B. Add weight every session. The goal is building a strong base with low-rep, high-intensity compounds.",
        days: [
            ProgramDay(id: UUID(), name: "Workout A", weekday: 2, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Bench Press", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 1, repTarget: 5)
            ]),
            ProgramDay(id: UUID(), name: "Workout B", weekday: 4, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "OHP (BB)", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 1, repTarget: 5)
            ]),
            ProgramDay(id: UUID(), name: "Workout A (repeat)", weekday: 6, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Bench Press", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Pull-Up", setCount: 3, repTarget: 8)
            ])
        ]
    )

    // MARK: - 2. GZCLP (Beginner, Strength, 3 days)
    private static let gzclp = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "GZCLP",
        level: .beginner,
        goal: .strength,
        daysPerWeek: 3,
        summary: "Tier-based novice program built on the GZCL method.",
        description: "A linear-progression take on Cody Lefever's GZCL method. Tier 1 is a heavy compound, Tier 2 is a volume compound, Tier 3 is accessory work. A clean next step after Starting Strength.",
        days: [
            ProgramDay(id: UUID(), name: "Day A1", weekday: 2, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 5, repTarget: 3, notes: "Tier 1"),
                ProgramItem(exerciseName: "Bench Press", setCount: 3, repTarget: 10, notes: "Tier 2"),
                ProgramItem(exerciseName: "Lat Pulldown", setCount: 3, repTarget: 15, notes: "Tier 3")
            ]),
            ProgramDay(id: UUID(), name: "Day B1", weekday: 4, items: [
                ProgramItem(exerciseName: "OHP (BB)", setCount: 5, repTarget: 3, notes: "Tier 1"),
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 3, repTarget: 10, notes: "Tier 2"),
                ProgramItem(exerciseName: "Single-Arm DB Row", setCount: 3, repTarget: 15, notes: "Tier 3")
            ]),
            ProgramDay(id: UUID(), name: "Day A2", weekday: 6, items: [
                ProgramItem(exerciseName: "Bench Press", setCount: 5, repTarget: 3, notes: "Tier 1"),
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 10, notes: "Tier 2"),
                ProgramItem(exerciseName: "Pull-Up", setCount: 3, repTarget: 15, notes: "Tier 3")
            ])
        ]
    )

    // MARK: - 3. Strong Curves (Beginner, Hypertrophy, 3 days)
    private static let strongCurves = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Strong Curves",
        level: .beginner,
        goal: .hypertrophy,
        daysPerWeek: 3,
        summary: "Glute-focused hypertrophy program with compound posterior-chain work.",
        description: "Bret Contreras's program built around the hip thrust as the centerpiece. Three full-body days heavy on glute-targeted compounds and accessories.",
        days: [
            ProgramDay(id: UUID(), name: "Workout A", weekday: 2, items: [
                ProgramItem(exerciseName: "Hip Thrust", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Romanian DL", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Walking Lunge", setCount: 2, repTarget: 12),
                ProgramItem(exerciseName: "Glute Bridge", setCount: 2, repTarget: 20)
            ]),
            ProgramDay(id: UUID(), name: "Workout B", weekday: 4, items: [
                ProgramItem(exerciseName: "Hip Thrust", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Bulgarian Split Squat", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "DB Romanian DL", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Cable Kickback", setCount: 3, repTarget: 15),
                ProgramItem(exerciseName: "Plank", setCount: 3, repTarget: 45)
            ]),
            ProgramDay(id: UUID(), name: "Workout C", weekday: 6, items: [
                ProgramItem(exerciseName: "Hip Thrust", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Goblet Squat", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Good Morning", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Step-Up", setCount: 3, repTarget: 10)
            ])
        ]
    )

    // MARK: - 4. Upper / Lower 4-Day (Intermediate, Mixed, 4 days)
    private static let upperLower4Day = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "Upper / Lower 4-Day",
        level: .intermediate,
        goal: .mixed,
        daysPerWeek: 4,
        summary: "Classic 4-day upper/lower split blending strength and volume.",
        description: "Two upper and two lower days per week. One session of each is strength-focused (lower reps), the other hypertrophy-focused (higher reps). Balanced, flexible, and scales well.",
        days: [
            ProgramDay(id: UUID(), name: "Upper — Strength", weekday: 2, items: [
                ProgramItem(exerciseName: "Bench Press", setCount: 4, repTarget: 5),
                ProgramItem(exerciseName: "Bent Over Row (BB)", setCount: 4, repTarget: 5),
                ProgramItem(exerciseName: "OHP (BB)", setCount: 3, repTarget: 6),
                ProgramItem(exerciseName: "Pull-Up", setCount: 3, repTarget: 8),
                ProgramItem(exerciseName: "Barbell Curl", setCount: 3, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Lower — Strength", weekday: 3, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 4, repTarget: 5),
                ProgramItem(exerciseName: "Romanian DL", setCount: 3, repTarget: 6),
                ProgramItem(exerciseName: "Leg Press", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Standing Calf Raise", setCount: 4, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Upper — Hypertrophy", weekday: 5, items: [
                ProgramItem(exerciseName: "Incline DB Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Seated Cable Row", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "DB Shoulder Press", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Lat Pulldown", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "DB Curl", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Triceps Pushdown", setCount: 3, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Lower — Hypertrophy", weekday: 6, items: [
                ProgramItem(exerciseName: "Front Squat", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Hip Thrust", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Leg Extension", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Hamstring Curl", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Seated Calf Raise", setCount: 4, repTarget: 15)
            ])
        ]
    )

    // MARK: - 5. 5/3/1 Boring But Big (Intermediate, Hypertrophy, 4 days)
    private static let fiveThreeOneBBB = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        name: "5/3/1 Boring But Big",
        level: .intermediate,
        goal: .hypertrophy,
        daysPerWeek: 4,
        summary: "Wendler's 5/3/1 paired with 5×10 volume work on the main lift.",
        description: "Each day hits one of the four main lifts using 5/3/1 percentages, then follows with 5×10 of the same lift at a lighter weight. Brutal volume, simple to run. Treat set counts here as a starting point — follow Wendler's percentage scheme for loading.",
        days: [
            ProgramDay(id: UUID(), name: "Press Day", weekday: 2, items: [
                ProgramItem(exerciseName: "OHP (BB)", setCount: 3, repTarget: 5, notes: "5/3/1 sets"),
                ProgramItem(exerciseName: "OHP (BB)", setCount: 5, repTarget: 10, notes: "BBB @ 50%"),
                ProgramItem(exerciseName: "Pull-Up", setCount: 5, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Deadlift Day", weekday: 3, items: [
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 3, repTarget: 5, notes: "5/3/1 sets"),
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 5, repTarget: 10, notes: "BBB @ 50%"),
                ProgramItem(exerciseName: "Hanging Leg Raise", setCount: 5, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Bench Day", weekday: 5, items: [
                ProgramItem(exerciseName: "Bench Press", setCount: 3, repTarget: 5, notes: "5/3/1 sets"),
                ProgramItem(exerciseName: "Bench Press", setCount: 5, repTarget: 10, notes: "BBB @ 50%"),
                ProgramItem(exerciseName: "Bent Over Row (BB)", setCount: 5, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Squat Day", weekday: 6, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 3, repTarget: 5, notes: "5/3/1 sets"),
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 5, repTarget: 10, notes: "BBB @ 50%"),
                ProgramItem(exerciseName: "Plank", setCount: 3, repTarget: 45)
            ])
        ]
    )

    // MARK: - 6. Metallicadpa PPL (Intermediate, Mixed, 6 days)
    private static let metallicadpaPPL = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        name: "Metallicadpa PPL",
        level: .intermediate,
        goal: .mixed,
        daysPerWeek: 6,
        summary: "The Reddit-famous 6-day Push/Pull/Legs rotation.",
        description: "High-frequency push/pull/legs with one heavy and one volume rotation per lift. Run two push, two pull, two legs days per week.",
        days: [
            ProgramDay(id: UUID(), name: "Push A (Heavy)", weekday: 2, items: [
                ProgramItem(exerciseName: "Bench Press", setCount: 4, repTarget: 6),
                ProgramItem(exerciseName: "OHP (BB)", setCount: 3, repTarget: 8),
                ProgramItem(exerciseName: "Incline DB Press", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Triceps Pushdown", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Lateral Raise (DB)", setCount: 3, repTarget: 15)
            ]),
            ProgramDay(id: UUID(), name: "Pull A (Heavy)", weekday: 3, items: [
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 3, repTarget: 5),
                ProgramItem(exerciseName: "Pull-Up", setCount: 3, repTarget: 8),
                ProgramItem(exerciseName: "Bent Over Row (BB)", setCount: 3, repTarget: 8),
                ProgramItem(exerciseName: "Face Pull", setCount: 3, repTarget: 15),
                ProgramItem(exerciseName: "Barbell Curl", setCount: 3, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Legs A", weekday: 4, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 4, repTarget: 6),
                ProgramItem(exerciseName: "Romanian DL", setCount: 3, repTarget: 8),
                ProgramItem(exerciseName: "Leg Press", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Hamstring Curl", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Standing Calf Raise", setCount: 4, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Push B (Volume)", weekday: 5, items: [
                ProgramItem(exerciseName: "OHP (BB)", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Incline DB Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Pec Dec", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Lateral Raise (DB)", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Skullcrusher", setCount: 3, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Pull B (Volume)", weekday: 6, items: [
                ProgramItem(exerciseName: "Pull-Up", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Seated Cable Row", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Lat Pulldown", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Hammer Curl", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Rear Delt Fly", setCount: 3, repTarget: 15)
            ]),
            ProgramDay(id: UUID(), name: "Legs B", weekday: 7, items: [
                ProgramItem(exerciseName: "Front Squat", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Hip Thrust", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Leg Extension", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Bulgarian Split Squat", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Seated Calf Raise", setCount: 4, repTarget: 15)
            ])
        ]
    )

    // MARK: - 7. Dumbbell PPL (Intermediate, Hypertrophy, 6 days)
    private static let dumbbellPPL = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        name: "Dumbbell PPL",
        level: .intermediate,
        goal: .hypertrophy,
        daysPerWeek: 6,
        summary: "Six-day push/pull/legs using only dumbbells. Great for home gyms.",
        description: "All movements use dumbbells or bodyweight. Good option if you only own DBs or travel frequently. Runs the same push/pull/legs rotation twice a week.",
        days: [
            ProgramDay(id: UUID(), name: "Push A", weekday: 2, items: [
                ProgramItem(exerciseName: "DB Bench Press", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "DB Shoulder Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Incline DB Press", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Lateral Raise (DB)", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Triceps Extension", setCount: 4, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Pull A", weekday: 3, items: [
                ProgramItem(exerciseName: "Single-Arm DB Row", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Pull-Up", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Rear Delt Fly", setCount: 3, repTarget: 15),
                ProgramItem(exerciseName: "DB Curl", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Hammer Curl", setCount: 3, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Legs A", weekday: 4, items: [
                ProgramItem(exerciseName: "Goblet Squat", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "DB Romanian DL", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Bulgarian Split Squat", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "DB Calf Raise", setCount: 4, repTarget: 15)
            ]),
            ProgramDay(id: UUID(), name: "Push B", weekday: 5, items: [
                ProgramItem(exerciseName: "Incline DB Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Single-Arm DB Press", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "DB Fly", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Lateral Raise (DB)", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Push-Up", setCount: 3, repTarget: 15)
            ]),
            ProgramDay(id: UUID(), name: "Pull B", weekday: 6, items: [
                ProgramItem(exerciseName: "Single-Arm DB Row", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Chin-Up", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Rear Delt Fly", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "DB Curl", setCount: 4, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Legs B", weekday: 7, items: [
                ProgramItem(exerciseName: "Goblet Squat", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Walking Lunge", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "DB Romanian DL", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Step-Up", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "DB Calf Raise", setCount: 4, repTarget: 20)
            ])
        ]
    )

    // MARK: - 8. Arnold Split (Advanced, Hypertrophy, 6 days)
    private static let arnoldSplit = ProgramTemplate(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
        name: "Arnold Split",
        level: .advanced,
        goal: .hypertrophy,
        daysPerWeek: 6,
        summary: "Classic 6-day bodybuilding split: Chest/Back, Shoulders/Arms, Legs.",
        description: "Arnold's classic split runs each muscle pairing twice a week with high volume. Best for advanced lifters who can recover from frequent, high-volume sessions.",
        days: [
            ProgramDay(id: UUID(), name: "Chest / Back A", weekday: 2, items: [
                ProgramItem(exerciseName: "Bench Press", setCount: 5, repTarget: 8),
                ProgramItem(exerciseName: "Incline Bench Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "DB Fly", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Pull-Up", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Bent Over Row (BB)", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Deadlift (Conv)", setCount: 3, repTarget: 6)
            ]),
            ProgramDay(id: UUID(), name: "Shoulders / Arms A", weekday: 3, items: [
                ProgramItem(exerciseName: "OHP (BB)", setCount: 4, repTarget: 8),
                ProgramItem(exerciseName: "Lateral Raise (DB)", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Rear Delt Fly", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Barbell Curl", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Skullcrusher", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Hammer Curl", setCount: 3, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Legs A", weekday: 4, items: [
                ProgramItem(exerciseName: "Back Squat (BB)", setCount: 5, repTarget: 8),
                ProgramItem(exerciseName: "Romanian DL", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Leg Press", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Hamstring Curl", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Standing Calf Raise", setCount: 5, repTarget: 15)
            ]),
            ProgramDay(id: UUID(), name: "Chest / Back B", weekday: 5, items: [
                ProgramItem(exerciseName: "Incline DB Press", setCount: 5, repTarget: 10),
                ProgramItem(exerciseName: "Cable Crossover", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "Weighted Dips", setCount: 3, repTarget: 10),
                ProgramItem(exerciseName: "Chin-Up", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Seated Cable Row", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "T-Bar Row", setCount: 3, repTarget: 10)
            ]),
            ProgramDay(id: UUID(), name: "Shoulders / Arms B", weekday: 6, items: [
                ProgramItem(exerciseName: "DB Shoulder Press", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Cable Lateral Raise", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Face Pull", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Preacher Curl", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Triceps Pushdown", setCount: 4, repTarget: 12),
                ProgramItem(exerciseName: "DB Curl", setCount: 3, repTarget: 12)
            ]),
            ProgramDay(id: UUID(), name: "Legs B", weekday: 7, items: [
                ProgramItem(exerciseName: "Front Squat", setCount: 5, repTarget: 8),
                ProgramItem(exerciseName: "Hip Thrust", setCount: 4, repTarget: 10),
                ProgramItem(exerciseName: "Leg Extension", setCount: 4, repTarget: 15),
                ProgramItem(exerciseName: "Walking Lunge", setCount: 3, repTarget: 12),
                ProgramItem(exerciseName: "Seated Calf Raise", setCount: 5, repTarget: 15)
            ])
        ]
    )
}
