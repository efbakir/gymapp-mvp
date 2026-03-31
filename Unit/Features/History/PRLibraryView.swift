//
//  PRLibraryView.swift
//  Unit
//
//  Personal record list by exercise.
//

import SwiftUI

struct PRLibraryView: View {
    @Environment(\.dismiss) private var dismiss

    let sessions: [WorkoutSession]
    let exercises: [Exercise]

    private var records: [PRRecord] {
        let completedEntries = sessions
            .filter(\.isCompleted)
            .flatMap { $0.setEntries.filter(\.isCompleted) }

        let grouped = Dictionary(grouping: completedEntries, by: \.exerciseId)

        return grouped.compactMap { exerciseID, entries in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }) else { return nil }
            guard let best = entries.max(by: { lhs, rhs in
                lhs.weight == rhs.weight ? lhs.reps < rhs.reps : lhs.weight < rhs.weight
            }) else {
                return nil
            }
            return PRRecord(exerciseName: exercise.displayName, weight: best.weight, reps: best.reps, isBodyweight: exercise.isBodyweight)
        }
        .sorted { $0.exerciseName < $1.exerciseName }
    }

    var body: some View {
        AppScreen(
            title: "PR Library",
            navigationBarTitleDisplayMode: .inline
        ) {
            if records.isEmpty {
                AppCard {
                    VStack(spacing: AppSpacing.sm) {
                        AppIcon.trophy.image(size: 32, weight: .medium)
                            .foregroundStyle(AppColor.textSecondary)
                        Text("No PRs yet. Complete workouts to build your library.")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
                }
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(records) { record in
                        AppCard {
                            AppListRow(
                                title: record.exerciseName,
                                subtitle: "Best set"
                            ) {
                                Text(WorkoutTargetFormatter.actualText(weightKg: record.weight, setCount: 1, reps: record.reps, isBodyweight: record.isBodyweight))
                                    .font(AppFont.body.font)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PRRecord: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weight: Double
    let reps: Int
    let isBodyweight: Bool
}

#Preview {
    PRLibraryView(sessions: [], exercises: [])
}
