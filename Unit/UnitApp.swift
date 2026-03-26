//
//  UnitApp.swift
//  Unit
//
//  Adaptive Periodization Engine — iOS 18+, Swift 6, SwiftUI, SwiftData.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct UnitApp: App {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.atlaslog.app",
        category: "SwiftData"
    )

    private static let schema = Schema([
            Split.self,
            Exercise.self,
            DayTemplate.self,
            WorkoutSession.self,
            SetEntry.self,
            Cycle.self,
            ProgressionRule.self
        ])
    var sharedModelContainer: ModelContainer

    @MainActor
    init() {
        self.sharedModelContainer = Self.makeSharedModelContainer()
    }

    private static func makeSharedModelContainer() -> ModelContainer {
        let isRunningPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if isRunningPreviews {
            return makeInMemoryContainer(orDieWith: "Could not create preview ModelContainer.")
        }

        do {
            let storeURL = try persistentStoreURL()
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            return try makePersistentContainer(configuration: configuration)
        } catch {
            logger.error("Persistent ModelContainer failed. Falling back to in-memory store. Error: \(String(describing: error), privacy: .public)")
            return makeInMemoryContainer(orDieWith: "Could not create fallback ModelContainer.")
        }
    }

    private static func makePersistentContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            logger.error("Persistent store open failed. Resetting local store. Error: \(String(describing: error), privacy: .public)")
            resetStoreFiles(at: configuration.url)
            return try ModelContainer(for: schema, configurations: [configuration])
        }
    }

    private static func makeInMemoryContainer(orDieWith message: String) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("\(message) \(error)")
        }
    }

    private static func persistentStoreURL() throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = appSupportURL.appendingPathComponent("Unit", isDirectory: true)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        return directoryURL.appendingPathComponent("Unit.store")
    }

    private static func resetStoreFiles(at storeURL: URL) {
        let fileManager = FileManager.default
        let sidecarURLs = [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-shm"),
            URL(fileURLWithPath: storeURL.path + "-wal")
        ]

        for url in sidecarURLs where fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                logger.error("Failed to remove store file at \(url.path, privacy: .public): \(String(describing: error), privacy: .public)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

enum PreviewSampleData {
    private static let fightCampSplitName = "Fight Camp Performance"
    private static let fightCampCycleName = "Fight Camp Performance — Demo"

    private struct ExerciseSeed {
        let name: String
        let aliases: [String]
        let isBodyweight: Bool
        let baseWeightKg: Double
        let reps: Int
        let incrementKg: Double
    }

    private struct SeededSessionExercise {
        let name: String
        let weightKg: Double
        let reps: Int
        let sets: Int
    }

    private static let exerciseSeeds: [ExerciseSeed] = [
        .init(name: "Trap Bar Deadlift", aliases: ["Trap Bar"], isBodyweight: false, baseWeightKg: 140, reps: 4, incrementKg: 5),
        .init(name: "Weighted Pull-Up", aliases: ["Pull-Up"], isBodyweight: false, baseWeightKg: 15, reps: 5, incrementKg: 2.5),
        .init(name: "Landmine Punch Press", aliases: ["Landmine Punch"], isBodyweight: false, baseWeightKg: 30, reps: 5, incrementKg: 2.5),
        .init(name: "Face Pull", aliases: [], isBodyweight: false, baseWeightKg: 27.5, reps: 15, incrementKg: 2.5),
        .init(name: "Hamstring Curl", aliases: [], isBodyweight: false, baseWeightKg: 40, reps: 12, incrementKg: 2.5),
        .init(name: "Push-Up Plus", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 15, incrementKg: 0),
        .init(name: "Pallof Press", aliases: [], isBodyweight: false, baseWeightKg: 20, reps: 10, incrementKg: 1.25),
        .init(name: "Copenhagen Plank", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 20, incrementKg: 0),
        .init(name: "Broad Jump", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 3, incrementKg: 0),
        .init(name: "Med Ball Overhead Slam", aliases: [], isBodyweight: false, baseWeightKg: 10, reps: 5, incrementKg: 1.25),
        .init(name: "Agility Ladder", aliases: ["Quick Footwork"], isBodyweight: true, baseWeightKg: 0, reps: 5, incrementKg: 0),
        .init(name: "Ab Wheel", aliases: ["AB Roller"], isBodyweight: true, baseWeightKg: 0, reps: 10, incrementKg: 0),
        .init(name: "Neck Work", aliases: ["Neck"], isBodyweight: true, baseWeightKg: 0, reps: 10, incrementKg: 0),
        .init(name: "Hang Power Clean", aliases: [], isBodyweight: false, baseWeightKg: 60, reps: 3, incrementKg: 2.5),
        .init(name: "Bench Press", aliases: [], isBodyweight: false, baseWeightKg: 80, reps: 6, incrementKg: 2.5),
        .init(name: "Pendlay Row", aliases: [], isBodyweight: false, baseWeightKg: 70, reps: 6, incrementKg: 2.5),
        .init(name: "Suitcase Carry", aliases: [], isBodyweight: false, baseWeightKg: 30, reps: 20, incrementKg: 2.5),
        .init(name: "Skater Bounds", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 4, incrementKg: 0),
        .init(name: "Back Extension", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 12, incrementKg: 0),
        .init(name: "Neck Flexion", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 15, incrementKg: 0),
        .init(name: "Biceps Curl", aliases: ["Biceps"], isBodyweight: false, baseWeightKg: 16, reps: 12, incrementKg: 1.25),
        .init(name: "Triceps Extension", aliases: ["Triceps"], isBodyweight: false, baseWeightKg: 15, reps: 12, incrementKg: 1.25),
        .init(name: "Zone 2 Cardio", aliases: ["Zone 2"], isBodyweight: true, baseWeightKg: 0, reps: 45, incrementKg: 0),
        .init(name: "Footwork Drill", aliases: ["Advance-Retreat"], isBodyweight: true, baseWeightKg: 0, reps: 15, incrementKg: 0),
        .init(name: "Zercher Deadlift", aliases: [], isBodyweight: false, baseWeightKg: 90, reps: 3, incrementKg: 5),
        .init(name: "Overhead Press", aliases: ["OHP"], isBodyweight: false, baseWeightKg: 50, reps: 4, incrementKg: 2.5),
        .init(name: "Hamstring / Calf Iso", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 60, incrementKg: 0),
        .init(name: "Bulgarian Split Squat", aliases: [], isBodyweight: false, baseWeightKg: 30, reps: 8, incrementKg: 2.5),
        .init(name: "Single-Arm DB Row", aliases: [], isBodyweight: false, baseWeightKg: 40, reps: 10, incrementKg: 2.5),
        .init(name: "Single-Arm Cable Press", aliases: [], isBodyweight: false, baseWeightKg: 25, reps: 8, incrementKg: 2.5),
        .init(name: "Heavy Curl", aliases: [], isBodyweight: false, baseWeightKg: 20, reps: 10, incrementKg: 2.5),
        .init(name: "Heavy DB Shrug", aliases: [], isBodyweight: false, baseWeightKg: 42.5, reps: 12, incrementKg: 2.5),
        .init(name: "KB Combination", aliases: [], isBodyweight: false, baseWeightKg: 24, reps: 4, incrementKg: 2.5),
        .init(name: "Rotational Med Ball Throw", aliases: [], isBodyweight: false, baseWeightKg: 10, reps: 5, incrementKg: 2.5),
        .init(name: "Plyo Push-Up", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 5, incrementKg: 0),
        .init(name: "Bird Dog", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 10, incrementKg: 0),
        .init(name: "Dynamic Hugs", aliases: [], isBodyweight: false, baseWeightKg: 17.5, reps: 15, incrementKg: 2.5),
        .init(name: "4-Way Neck Isometric", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 10, incrementKg: 0),
        .init(name: "HIIT Intervals", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 4, incrementKg: 0),
        .init(name: "Easy Warm-Up + Drills", aliases: [], isBodyweight: true, baseWeightKg: 0, reps: 10, incrementKg: 0)
    ]

    private static let programDays: [(name: String, exercises: [String])] = [
        ("Day 1 · Strength + Upper Body", [
            "Trap Bar Deadlift", "Weighted Pull-Up", "Landmine Punch Press", "Face Pull",
            "Hamstring Curl", "Push-Up Plus", "Pallof Press", "Copenhagen Plank",
            "Broad Jump", "Med Ball Overhead Slam", "Agility Ladder", "Ab Wheel", "Neck Work"
        ]),
        ("Day 2 · Full Body Power", [
            "Hang Power Clean", "Bench Press", "Pendlay Row", "Suitcase Carry",
            "Ab Wheel", "Skater Bounds", "Back Extension", "Neck Flexion",
            "Biceps Curl", "Triceps Extension"
        ]),
        ("Day 3 · Zone 2 + Footwork", [
            "Zone 2 Cardio", "Footwork Drill"
        ]),
        ("Day 4 · SIT Day", [
            "Zercher Deadlift", "Overhead Press", "Weighted Pull-Up", "Landmine Punch Press",
            "Suitcase Carry", "Hamstring Curl", "Pallof Press", "Hamstring / Calf Iso",
            "Ab Wheel", "Neck Work", "Push-Up Plus", "Face Pull"
        ]),
        ("Day 5 · Unilateral + Rotational Force", [
            "Rotational Med Ball Throw", "Bird Dog", "KB Combination", "Plyo Push-Up",
            "Bulgarian Split Squat", "Single-Arm Cable Press", "Single-Arm DB Row",
            "4-Way Neck Isometric", "Heavy Curl", "Dynamic Hugs", "Heavy DB Shrug"
        ]),
        ("Day 6 · HIIT Day", [
            "HIIT Intervals", "Easy Warm-Up + Drills"
        ])
    ]

    private static let seededDayFiveSession: [SeededSessionExercise] = [
        .init(name: "Rotational Med Ball Throw", weightKg: 10, reps: 5, sets: 3),
        .init(name: "Bird Dog", weightKg: 0, reps: 10, sets: 3),
        .init(name: "KB Combination", weightKg: 24, reps: 4, sets: 3),
        .init(name: "Plyo Push-Up", weightKg: 0, reps: 5, sets: 3),
        .init(name: "Bulgarian Split Squat", weightKg: 30, reps: 8, sets: 3),
        .init(name: "Single-Arm Cable Press", weightKg: 25, reps: 8, sets: 3),
        .init(name: "Single-Arm DB Row", weightKg: 40, reps: 10, sets: 3),
        .init(name: "4-Way Neck Isometric", weightKg: 0, reps: 10, sets: 2),
        .init(name: "Heavy Curl", weightKg: 20, reps: 10, sets: 3),
        .init(name: "Dynamic Hugs", weightKg: 17.5, reps: 15, sets: 3),
        .init(name: "Heavy DB Shrug", weightKg: 42.5, reps: 12, sets: 3)
    ]

    @MainActor
    static func makePreviewContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = buildContainer(config: config) else {
            preconditionFailure("Preview container creation failed.")
        }
        _ = seedIfNeeded(in: container.mainContext)
        return container
    }

    @MainActor
    private static func buildContainer(config: ModelConfiguration) -> ModelContainer? {
        try? ModelContainer(
            for: Split.self,
            Exercise.self,
            DayTemplate.self,
            WorkoutSession.self,
            SetEntry.self,
            Cycle.self,
            ProgressionRule.self,
            configurations: config
        )
    }

    @MainActor
    @discardableResult
    static func seedIfNeeded(in modelContext: ModelContext) -> Bool {
        if let existing = try? modelContext.fetch(FetchDescriptor<Split>()), !existing.isEmpty {
            return false
        }
        return ensureFightCampProgramForCurrentUser(in: modelContext)
    }

    @MainActor
    @discardableResult
    static func ensureFightCampProgramForCurrentUser(in modelContext: ModelContext) -> Bool {
        let allExercises = (try? modelContext.fetch(FetchDescriptor<Exercise>())) ?? []
        let allSplits = (try? modelContext.fetch(FetchDescriptor<Split>())) ?? []
        let allTemplates = (try? modelContext.fetch(FetchDescriptor<DayTemplate>())) ?? []
        let allCycles = (try? modelContext.fetch(FetchDescriptor<Cycle>())) ?? []
        let allRules = (try? modelContext.fetch(FetchDescriptor<ProgressionRule>())) ?? []
        let allSessions = (try? modelContext.fetch(FetchDescriptor<WorkoutSession>())) ?? []

        var didChange = false

        func normalized(_ value: String) -> String {
            value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        }

        func exerciseMatches(_ exercise: Exercise, seed: ExerciseSeed) -> Bool {
            let names = [exercise.displayName] + exercise.aliases
            let desiredNames = [seed.name] + seed.aliases
            let normalizedNames = Set(names.map(normalized))
            return desiredNames.map(normalized).contains(where: normalizedNames.contains)
        }

        var exerciseByName: [String: Exercise] = [:]
        for seed in exerciseSeeds {
            if let existingExercise = allExercises.first(where: { exerciseMatches($0, seed: seed) }) {
                exerciseByName[seed.name] = existingExercise
                continue
            }

            let exercise = Exercise(
                displayName: seed.name,
                aliases: seed.aliases,
                isBodyweight: seed.isBodyweight
            )
            modelContext.insert(exercise)
            exerciseByName[seed.name] = exercise
            didChange = true
        }

        let split = allSplits.first(where: { normalized($0.name) == normalized(fightCampSplitName) }) ?? {
            let split = Split(name: fightCampSplitName)
            modelContext.insert(split)
            didChange = true
            return split
        }()

        let templatesForSplit = allTemplates.filter { $0.splitId == split.id }
        var orderedTemplates: [DayTemplate] = []

        for day in programDays {
            let exerciseIDs = day.exercises.compactMap { exerciseByName[$0]?.id }
            let template = templatesForSplit.first(where: { normalized($0.name) == normalized(day.name) }) ?? {
                let template = DayTemplate(name: day.name, splitId: split.id, orderedExerciseIds: exerciseIDs)
                modelContext.insert(template)
                didChange = true
                return template
            }()

            if template.splitId != split.id {
                template.splitId = split.id
                didChange = true
            }

            if template.orderedExerciseIds != exerciseIDs {
                template.orderedExerciseIds = exerciseIDs
                didChange = true
            }

            orderedTemplates.append(template)
        }

        let orderedTemplateIDs = orderedTemplates.map(\.id)
        if split.orderedTemplateIds != orderedTemplateIDs {
            split.orderedTemplateIds = orderedTemplateIDs
            didChange = true
        }

        var mondayBasedCalendar = Calendar(identifier: .gregorian)
        mondayBasedCalendar.locale = .current
        mondayBasedCalendar.timeZone = .current
        mondayBasedCalendar.firstWeekday = 2

        let today = mondayBasedCalendar.startOfDay(for: Date())
        let currentWeekStart = mondayBasedCalendar.date(
            from: mondayBasedCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        ) ?? today
        let cycleStart = mondayBasedCalendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? today

        let cycle = allCycles.first(where: { $0.splitId == split.id }) ?? {
            let cycle = Cycle(
                name: fightCampCycleName,
                splitId: split.id,
                startDate: cycleStart,
                weekCount: 8,
                globalIncrementKg: 2.5,
                isActive: true,
                isCompleted: false
            )
            modelContext.insert(cycle)
            didChange = true
            return cycle
        }()

        if cycle.name != fightCampCycleName {
            cycle.name = fightCampCycleName
            didChange = true
        }

        if cycle.splitId != split.id {
            cycle.splitId = split.id
            didChange = true
        }

        if cycle.startDate != cycleStart {
            cycle.startDate = cycleStart
            didChange = true
        }

        if cycle.weekCount != 8 {
            cycle.weekCount = 8
            didChange = true
        }

        if cycle.globalIncrementKg != 2.5 {
            cycle.globalIncrementKg = 2.5
            didChange = true
        }

        if cycle.isCompleted {
            cycle.isCompleted = false
            didChange = true
        }

        for existingCycle in allCycles where existingCycle.id != cycle.id && existingCycle.isActive {
            existingCycle.isActive = false
            didChange = true
        }

        if !cycle.isActive {
            cycle.isActive = true
            didChange = true
        }

        let seedByName = Dictionary(uniqueKeysWithValues: exerciseSeeds.map { ($0.name, $0) })
        var seenExerciseIDs = Set<UUID>()

        for day in programDays {
            for exerciseName in day.exercises {
                guard let exercise = exerciseByName[exerciseName],
                      let seed = seedByName[exerciseName],
                      !seenExerciseIDs.contains(exercise.id) else { continue }

                seenExerciseIDs.insert(exercise.id)

                if let existingRule = allRules.first(where: { $0.cycleId == cycle.id && $0.exerciseId == exercise.id }) {
                    if existingRule.incrementKg != seed.incrementKg {
                        existingRule.incrementKg = seed.incrementKg
                        didChange = true
                    }
                    if existingRule.baseWeightKg != seed.baseWeightKg {
                        existingRule.baseWeightKg = seed.baseWeightKg
                        didChange = true
                    }
                    if existingRule.baseReps != seed.reps {
                        existingRule.baseReps = seed.reps
                        didChange = true
                    }
                    continue
                }

                modelContext.insert(
                    ProgressionRule(
                        cycleId: cycle.id,
                        exerciseId: exercise.id,
                        incrementKg: seed.incrementKg,
                        baseWeightKg: seed.baseWeightKg,
                        baseReps: seed.reps
                    )
                )
                didChange = true
            }
        }

        if let firstTemplate = orderedTemplates.first,
           !allSessions.contains(where: { $0.cycleId == cycle.id && $0.templateId == firstTemplate.id }) {
            let session = WorkoutSession(
                date: cycleStart,
                templateId: firstTemplate.id,
                isCompleted: true,
                overallFeeling: 4,
                cycleId: cycle.id,
                weekNumber: 1
            )
            modelContext.insert(session)

            let demoEntries: [(String, Double, Int)] = [
                ("Trap Bar Deadlift", 140, 4),
                ("Weighted Pull-Up", 15, 5),
                ("Landmine Punch Press", 30, 5),
                ("Face Pull", 27.5, 15),
                ("Hamstring Curl", 40, 12),
                ("Pallof Press", 20, 10)
            ]

            for (index, entry) in demoEntries.enumerated() {
                guard let exercise = exerciseByName[entry.0] else { continue }
                let setEntry = SetEntry(
                    sessionId: session.id,
                    exerciseId: exercise.id,
                    weight: entry.1,
                    reps: entry.2,
                    targetWeight: entry.1,
                    targetReps: entry.2,
                    metTarget: true,
                    isWarmup: false,
                    isCompleted: true,
                    setIndex: index
                )
                setEntry.session = session
                modelContext.insert(setEntry)
            }

            firstTemplate.lastPerformedDate = cycleStart
            didChange = true
        }

        if orderedTemplates.count >= 5 {
            let dayFiveTemplate = orderedTemplates[4]
            let dayFiveDate = mondayBasedCalendar.date(byAdding: .day, value: 4, to: cycleStart) ?? cycleStart

            if !allSessions.contains(where: { $0.cycleId == cycle.id && $0.templateId == dayFiveTemplate.id }) {
                let session = WorkoutSession(
                    date: dayFiveDate,
                    templateId: dayFiveTemplate.id,
                    isCompleted: true,
                    overallFeeling: 4,
                    cycleId: cycle.id,
                    weekNumber: 1
                )
                modelContext.insert(session)

                var setIndex = 0
                for seededExercise in seededDayFiveSession {
                    guard let exercise = exerciseByName[seededExercise.name] else { continue }

                    for _ in 0..<seededExercise.sets {
                        let setEntry = SetEntry(
                            sessionId: session.id,
                            exerciseId: exercise.id,
                            weight: seededExercise.weightKg,
                            reps: seededExercise.reps,
                            targetWeight: seededExercise.weightKg,
                            targetReps: seededExercise.reps,
                            metTarget: true,
                            isWarmup: false,
                            isCompleted: true,
                            setIndex: setIndex
                        )
                        setEntry.session = session
                        modelContext.insert(setEntry)
                        setIndex += 1
                    }
                }

                dayFiveTemplate.lastPerformedDate = dayFiveDate
                didChange = true
            }
        }

        if didChange {
            try? modelContext.save()
        }

        return didChange
    }

    @MainActor
    static func hasAnyProgram(in modelContext: ModelContext) -> Bool {
        ((try? modelContext.fetch(FetchDescriptor<Split>())) ?? []).isEmpty == false
    }
}
