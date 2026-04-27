//
//  TemplateDetailView.swift
//  Unit
//
//  Day detail: exercise list with ghost values, swipe to remove, press-and-hold to reorder.
//

import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Bindable var template: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @State private var showingAddExercise = false

    private var orderedExercises: [Exercise] {
        template.orderedExerciseIds.compactMap { id in
            exercises.first(where: { $0.id == id })
        }
    }

    private var navigationTitleRaw: String {
        let trimmed = template.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Day" : trimmed
    }

    private var cardListInsets: EdgeInsets {
        EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.md, bottom: AppSpacing.xs, trailing: AppSpacing.md)
    }

    var body: some View {
        List {
            if !orderedExercises.isEmpty {
                Text("Press and hold to reorder. Swipe left on a card to remove.")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowInsets(cardListInsets)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if orderedExercises.isEmpty {
                AppCard {
                    Text("No exercises yet.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
                .listRowInsets(cardListInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(orderedExercises, id: \.id) { exercise in
                    exerciseRowCard(exercise)
                }
                .onMove(perform: reorderExercises)
            }

            Button {
                showingAddExercise = true
            } label: {
                AppCard {
                    HStack(spacing: AppSpacing.sm) {
                        AppIcon.addCircle.image()
                        Text("Add Exercise")
                            .font(AppFont.body.font)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(AppColor.accent)
                    .frame(minHeight: 44, alignment: .leading)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .listRowInsets(cardListInsets)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, AppSpacing.sm, for: .scrollContent)
        .appScrollEdgeSoft()
        // `onMove` uses press-and-hold then drag (system behavior); no `EditMode` so we avoid extra list chrome.
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationTitleRaw)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: 240)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseToTemplateView(template: template)
                .appBottomSheetChrome()
        }
        .tint(AppColor.systemTint)
    }

    private func exerciseRowCard(_ exercise: Exercise) -> some View {
        AppCard {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                Text(exercise.displayName)
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                exerciseTargetSubtitle(for: exercise)
            }
        }
        .frame(minHeight: 44)
        .listRowInsets(cardListInsets)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                removeExercise(exercise.id)
            } label: {
                Label("Remove", systemImage: AppIcon.trash.systemName)
            }
        }
    }

    @ViewBuilder
    private func exerciseTargetSubtitle(for exercise: Exercise) -> some View {
        if let planned = plannedTargetDisplay(for: exercise) {
            Text(WorkoutTargetFormatter.setRepCompact(setCount: planned.setCount, reps: planned.reps) ?? "")
                .font(AppFont.performance)
                .foregroundStyle(AppColor.textPrimary)
                .monospacedDigit()
        } else {
            Text(ghostEmptySubtitle(for: exercise))
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private func ghostEmptySubtitle(for exercise: Exercise) -> String {
        let hasAnyCompleted = sessions.contains(where: \.isCompleted)
        if !hasAnyCompleted {
            return AppCopy.EmptyState.noHistoryYet
        }
        return AppCopy.EmptyState.noPriorSets
    }

    private struct PlannedTargetDisplay {
        let setCount: Int
        let reps: Int
    }

    private func plannedTargetDisplay(for exercise: Exercise) -> PlannedTargetDisplay? {
        // Ghost value: last completed set for this exercise across all sessions
        guard let lastSession = sessions.first(where: {
            $0.isCompleted &&
            $0.setEntries.contains(where: { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup })
        }) else {
            return nil
        }

        let sets = lastSession.setEntries
            .filter { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup }
            .sorted { $0.setIndex < $1.setIndex }

        guard let lastSet = sets.last, lastSet.reps > 0 else { return nil }

        let setCount = max(sets.count, 1)

        if !exercise.isBodyweight, lastSet.weight <= 0 {
            return nil
        }

        return PlannedTargetDisplay(setCount: setCount, reps: lastSet.reps)
    }

    private func reorderExercises(from source: IndexSet, to destination: Int) {
        var ids = template.orderedExerciseIds
        ids.move(fromOffsets: source, toOffset: destination)
        template.orderedExerciseIds = ids
        try? modelContext.save()
    }

    private func removeExercise(_ exerciseID: UUID) {
        var ids = template.orderedExerciseIds
        ids.removeAll { $0 == exerciseID }
        template.orderedExerciseIds = ids
        try? modelContext.save()
    }

}

struct AddExerciseToTemplateView: View {
    let template: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    @State private var query = ""

    private var availableExercises: [Exercise] {
        let inTemplate = Set(template.orderedExerciseIds)
        return exercises.filter { !inTemplate.contains($0.id) }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredExercises: [Exercise] {
        guard !trimmedQuery.isEmpty else { return availableExercises }
        let needle = trimmedQuery.lowercased()
        return availableExercises.filter { exercise in
            if exercise.displayName.lowercased().contains(needle) {
                return true
            }
            return exercise.aliases.contains { $0.lowercased().contains(needle) }
        }
    }

    private var hasExactNameMatch: Bool {
        exercises.contains {
            $0.displayName.compare(
                trimmedQuery,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) == .orderedSame
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises, id: \.id) { exercise in
                    Button {
                        addExercise(exercise)
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Text(exercise.displayName)
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textPrimary)

                            Spacer()

                            AppIcon.add.image()
                                .foregroundStyle(AppColor.accent)
                        }
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .listRowSeparator(.hidden)
                    .listRowBackground(AppColor.cardBackground)
                }

                if filteredExercises.isEmpty {
                    Text(trimmedQuery.isEmpty ? "No exercises yet" : "No matching exercises")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(minHeight: 44, alignment: .leading)
                        .listRowSeparator(.hidden)
                        .listRowBackground(AppColor.cardBackground)
                }

                if !trimmedQuery.isEmpty && !hasExactNameMatch {
                    Button {
                        createAndAdd()
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            AppIcon.addCircle.image()
                            Text("Create \"\(trimmedQuery)\"")
                                .font(AppFont.body.font)
                        }
                        .foregroundStyle(AppColor.accent)
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .listRowSeparator(.hidden)
                    .listRowBackground(AppColor.cardBackground)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
            .appScrollEdgeSoft()
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
            }
            .appNavigationBarChrome()
            .tint(AppColor.systemTint)
        }
    }

    private func addExercise(_ exercise: Exercise) {
        var ids = template.orderedExerciseIds
        ids.append(exercise.id)
        template.orderedExerciseIds = ids
        try? modelContext.save()
        dismiss()
    }

    private func createAndAdd() {
        let exercise = Exercise(displayName: trimmedQuery)
        modelContext.insert(exercise)

        var ids = template.orderedExerciseIds
        ids.append(exercise.id)
        template.orderedExerciseIds = ids

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        let container = PreviewSampleData.makePreviewContainer()
        let template = (try? container.mainContext.fetch(FetchDescriptor<DayTemplate>()))?.first

        return Group {
            if let template {
                TemplateDetailView(template: template)
                    .modelContainer(container)
            }
        }
    }
}
