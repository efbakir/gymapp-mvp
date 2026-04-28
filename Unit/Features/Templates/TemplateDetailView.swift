//
//  TemplateDetailView.swift
//  Unit
//
//  Day detail: exercise list with ghost values; drag the handle to reorder, tap × to remove.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TemplateDetailView: View {
    @Bindable var template: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @State private var showingAddExercise = false
    @State private var draggedExerciseID: UUID?

    private var orderedExercises: [Exercise] {
        template.orderedExerciseIds.compactMap { id in
            exercises.first(where: { $0.id == id })
        }
    }

    private var navigationTitleRaw: String {
        let trimmed = template.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Day" : trimmed
    }

    var body: some View {
        AppScreen(showsNativeNavigationBar: true) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if orderedExercises.isEmpty {
                    Text("No exercises yet.")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .appCardStyle()
                } else {
                    AppCardList(orderedExercises) { exercise in
                        exerciseRow(exercise)
                    }
                }

                AppGhostButton("Add Exercise") {
                    showingAddExercise = true
                }
            }
        }
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

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: AppSpacing.sm) {
            AppIcon.reorder.image(size: 15, weight: .semibold)
                .foregroundStyle(AppColor.textSecondary)
                .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
                .onDrag {
                    draggedExerciseID = exercise.id
                    return NSItemProvider(object: exercise.id.uuidString as NSString)
                }

            Text(exercise.displayName)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            exerciseTargetSubtitle(for: exercise)

            Button {
                removeExercise(exercise.id)
            } label: {
                AppIcon.close.image(size: 15, weight: .semibold)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Remove \(exercise.displayName)")
        }
        .frame(height: 48)
        .contentShape(Rectangle())
        .onDrop(
            of: [UTType.text],
            delegate: TemplateExerciseReorderDropDelegate(
                targetExerciseID: exercise.id,
                template: template,
                modelContext: modelContext,
                draggedExerciseID: $draggedExerciseID,
                reduceMotion: reduceMotion
            )
        )
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
        if let lastSession = sessions.first(where: {
            $0.isCompleted &&
            $0.setEntries.contains(where: { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup })
        }) {
            let sets = lastSession.setEntries
                .filter { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup }
                .sorted { $0.setIndex < $1.setIndex }

            if let lastSet = sets.last, lastSet.reps > 0,
               exercise.isBodyweight || lastSet.weight > 0 {
                return PlannedTargetDisplay(setCount: max(sets.count, 1), reps: lastSet.reps)
            }
        }

        // Cold-start fallback: planned values from onboarding.
        if let plannedSets = template.plannedSets(for: exercise.id), plannedSets > 0,
           let plannedReps = template.plannedReps(for: exercise.id), plannedReps > 0 {
            return PlannedTargetDisplay(setCount: plannedSets, reps: plannedReps)
        }

        return nil
    }

    private func removeExercise(_ exerciseID: UUID) {
        var ids = template.orderedExerciseIds
        ids.removeAll { $0 == exerciseID }
        template.orderedExerciseIds = ids
        try? modelContext.save()
    }

}

private struct TemplateExerciseReorderDropDelegate: DropDelegate {
    let targetExerciseID: UUID
    let template: DayTemplate
    let modelContext: ModelContext
    @Binding var draggedExerciseID: UUID?
    var reduceMotion: Bool = false

    func dropEntered(info: DropInfo) {
        guard let draggedExerciseID,
              draggedExerciseID != targetExerciseID,
              let fromIndex = template.orderedExerciseIds.firstIndex(of: draggedExerciseID),
              let toIndex = template.orderedExerciseIds.firstIndex(of: targetExerciseID) else {
            return
        }

        withAnimation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.9)) {
            var ids = template.orderedExerciseIds
            let moved = ids.remove(at: fromIndex)
            ids.insert(moved, at: toIndex)
            template.orderedExerciseIds = ids
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        try? modelContext.save()
        draggedExerciseID = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

struct AddExerciseToTemplateView: View {
    let template: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

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
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search exercises")
            .searchFocused($isSearchFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .onSubmit(of: .search) {
                guard !trimmedQuery.isEmpty, !hasExactNameMatch else { return }
                createAndAdd()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", role: .cancel) { dismiss() }
                }
            }
            .appNavigationBarChrome()
            .tint(AppColor.systemTint)
            .onAppear { isSearchFocused = true }
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
