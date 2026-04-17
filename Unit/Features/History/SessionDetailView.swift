//
//  SessionDetailView.swift
//  Unit
//
//  Read-only session detail grouped by exercise.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: WorkoutSession
    let templateName: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    private var exerciseSnapshots: [SessionExerciseSnapshot] {
        let grouped = Dictionary(grouping: session.setEntries.filter(\.isCompleted), by: \.exerciseId)
        return grouped.compactMap { exerciseID, entries -> SessionExerciseSnapshot? in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }) else { return nil }
            let sortedEntries = entries.sorted { $0.setIndex < $1.setIndex }
            let sets = sortedEntries.map { entry in
                SessionSetSnapshot(
                    id: entry.id,
                    setIndex: entry.setIndex,
                    actualWeight: entry.weight,
                    actualReps: entry.reps,
                    note: entry.note.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            return SessionExerciseSnapshot(
                id: exerciseID,
                name: exercise.displayName,
                isBodyweight: exercise.isBodyweight,
                sets: sets
            )
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        AppScreen(
            showsNativeNavigationBar: true
        ) {
            Text(templateName)
                .font(AppFont.title.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !exerciseSnapshots.isEmpty {
                AppCard {
                    AppDividedList(exerciseSnapshots) { exercise in
                        SessionExerciseSummary(exercise: exercise)
                            .padding(.vertical, AppSpacing.md)
                    }
                }
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
    }

}

#Preview {
    NavigationStack {
        let container = PreviewSampleData.makePreviewContainer()
        let session = (try? container.mainContext.fetch(FetchDescriptor<WorkoutSession>()))?.first

        Group {
            if let session {
                SessionDetailView(session: session, templateName: "Push")
                    .modelContainer(container)
            }
        }
    }
}
