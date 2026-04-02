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
    @State private var showingFeelingPicker = false

    private var exerciseSnapshots: [SessionExerciseSnapshot] {
        let grouped = Dictionary(grouping: session.setEntries.filter(\.isCompleted), by: \.exerciseId)
        return grouped.compactMap { exerciseID, entries -> SessionExerciseSnapshot? in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }) else { return nil }
            let sortedEntries = entries.sorted { $0.setIndex < $1.setIndex }
            let sets = sortedEntries.map { entry in
                SessionSetSnapshot(
                    id: entry.id,
                    setIndex: entry.setIndex,
                    targetWeight: entry.targetWeight,
                    targetReps: entry.targetReps,
                    actualWeight: entry.weight,
                    actualReps: entry.reps,
                    metTarget: entry.targetWeight > 0 || entry.targetReps > 0 ? entry.metTarget : true,
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
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(templateName)
                        .font(AppFont.sectionHeader.font)
                    Text(session.date, style: .date)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(session.date, style: .time)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            if !exerciseSnapshots.isEmpty {
                AppCard {
                    AppDividedList(exerciseSnapshots) { exercise in
                        SessionExerciseSummary(exercise: exercise)
                            .padding(.vertical, AppSpacing.smd)
                    }
                }
            }

            AppCard {
                Button {
                    showingFeelingPicker = true
                } label: {
                    AppListRow(title: "Overall feeling") {
                        if session.overallFeeling > 0 {
                            Text("\(session.overallFeeling)/5")
                                .font(AppFont.label.font)
                                .foregroundStyle(AppColor.accent)
                        } else {
                            Text("Tap to set")
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingFeelingPicker) {
            FeelingPickerView(session: session)
                .appBottomSheetChrome()
        }
    }

}

private struct FeelingPickerView: View {
    @Bindable var session: WorkoutSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("How did this workout feel?")
                    .font(AppFont.sectionHeader.font)

                HStack(spacing: AppSpacing.md) {
                    ForEach(1...5, id: \.self) { value in
                        Button("\(value)") {
                            session.overallFeeling = value
                            try? modelContext.save()
                            dismiss()
                        }
                        .font(AppFont.sectionHeader.font)
                        .frame(width: 44, height: 44)
                        .background(session.overallFeeling == value ? AppColor.accent : AppColor.controlBackground)
                        .foregroundStyle(session.overallFeeling == value ? AppColor.accentForeground : AppColor.textPrimary)
                        .clipShape(Circle())
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.md)
            .background(AppColor.sheetBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
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
