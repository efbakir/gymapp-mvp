//
//  TemplateDetailView.swift
//  Unit
//
//  Day detail: exercise list with targets (ProgressionEngine), edit control in nav bar.
//

import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    @Bindable var template: DayTemplate

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \Cycle.startDate, order: .reverse) private var cycles: [Cycle]
    @Query private var rules: [ProgressionRule]

    @State private var showingAddExercise = false
    @State private var isEditing = false

    private var activeCycle: Cycle? {
        cycles.first(where: { $0.isActive && !$0.isCompleted })
            ?? cycles.first(where: { !$0.isCompleted })
    }

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
            if isEditing {
                Text("Hold and drag to order")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                .listRowInsets(cardListInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if orderedExercises.isEmpty {
                AppCard {
                    Text(isEditing ? "Tap below to add your first exercise." : "No exercises yet.")
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
            }

            if isEditing {
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
                .buttonStyle(.plain)
                .listRowInsets(cardListInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, AppSpacing.sm, for: .scrollContent)
        .appScrollEdgeSoftTop(enabled: true)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isEditing.toggle()
                    }
                } label: {
                    (isEditing ? AppIcon.checkmark : AppIcon.edit).image(size: 18, weight: .semibold)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(AppColor.cardBackground)
                        }
                        .overlay {
                            Circle()
                                .stroke(AppColor.border.opacity(0.5), lineWidth: 0.5)
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isEditing ? "Done" : "Edit")
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseToTemplateView(template: template)
                .appBottomSheetChrome()
        }
        .tint(AppColor.accent)
    }

    private func exerciseRowCard(_ exercise: Exercise) -> some View {
        let row = HStack(alignment: .center, spacing: AppSpacing.sm) {
            AppCard {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(exercise.displayName)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)

                        exerciseTargetSubtitle(for: exercise)
                    }
                }
            }
            .frame(minHeight: 44)

            if isEditing {
                Button {
                    removeExercise(exercise.id)
                } label: {
                    AppIcon.trash.image(size: 13, weight: .semibold)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(AppColor.background)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        
        return reorderableExerciseRow(row, exerciseID: exercise.id)
            .listRowInsets(cardListInsets)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func reorderableExerciseRow<Content: View>(_ content: Content, exerciseID: UUID) -> some View {
        if isEditing {
            content
                .draggable(exerciseID.uuidString) {
                    Text(exercises.first(where: { $0.id == exerciseID })?.displayName ?? "Exercise")
                        .font(AppFont.body.font)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
                .dropDestination(for: String.self) { items, _ in
                    guard let first = items.first, let draggedID = UUID(uuidString: first) else { return false }
                    moveExercise(draggedID, before: exerciseID)
                    return true
                } isTargeted: { _ in }
        } else {
            content
        }
    }

    @ViewBuilder
    private func exerciseTargetSubtitle(for exercise: Exercise) -> some View {
        let setCount = lastWorkingSetCount(exerciseId: exercise.id)
        let planned = plannedTargetDisplay(for: exercise)
        let effectiveSetCount = max(setCount, 1)

        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let planned {
                Text(WorkoutTargetFormatter.volumeText(setCount: effectiveSetCount, reps: planned.reps) ?? "\(planned.reps) reps")
                    .font(AppFont.body.font.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .monospacedDigit()

                Text("Next")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)

                Text(planned.weightLine)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .monospacedDigit()
            }

            if setCount > 0, planned == nil {
                Text("\(setCount) set\(setCount == 1 ? "" : "s")")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .monospacedDigit()
            }
        }
    }

    private struct PlannedTargetDisplay {
        let setCount: Int
        let reps: Int
        let weightLine: String
    }

    private func plannedTargetDisplay(for exercise: Exercise) -> PlannedTargetDisplay? {
        guard let cycle = activeCycle, cycle.currentWeekNumber > 0,
              let rule = rules.first(where: { $0.cycleId == cycle.id && $0.exerciseId == exercise.id })
        else {
            return nil
        }
        let snapshot = rule.snapshot(weekCount: cycle.weekCount)
        let outcomes = rule.buildOutcomes(from: sessions)
        guard let target = ProgressionEngine.target(for: cycle.currentWeekNumber, rule: snapshot, outcomes: outcomes) else {
            return nil
        }
        guard target.reps > 0 else { return nil }
        let setCount = max(lastWorkingSetCount(exerciseId: exercise.id), 1)

        if exercise.isBodyweight {
            if target.weightKg == 0 {
                return PlannedTargetDisplay(setCount: setCount, reps: target.reps, weightLine: "Bodyweight")
            }
            return PlannedTargetDisplay(setCount: setCount, reps: target.reps, weightLine: "\(WorkoutTargetFormatter.weightDisplay(target.weightKg)) added")
        }

        guard target.weightKg > 0 else { return nil }
        return PlannedTargetDisplay(setCount: setCount, reps: target.reps, weightLine: WorkoutTargetFormatter.weightDisplay(target.weightKg))
    }

    private func lastWorkingSetCount(exerciseId: UUID) -> Int {
        let forDay = sessions.filter { $0.templateId == template.id && $0.isCompleted }
        guard let latest = forDay.max(by: { $0.date < $1.date }) else { return 0 }
        return latest.setEntries.filter { $0.exerciseId == exerciseId && $0.isCompleted && !$0.isWarmup }.count
    }

    private func removeExercise(_ exerciseID: UUID) {
        var ids = template.orderedExerciseIds
        ids.removeAll { $0 == exerciseID }
        template.orderedExerciseIds = ids
        try? modelContext.save()
    }

    private func moveExercise(_ draggedID: UUID, before targetID: UUID) {
        var ids = template.orderedExerciseIds
        guard draggedID != targetID,
              let sourceIndex = ids.firstIndex(of: draggedID),
              let targetIndex = ids.firstIndex(of: targetID)
        else { return }

        ids.remove(at: sourceIndex)
        let destinationIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        ids.insert(draggedID, at: destinationIndex)
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
                    .buttonStyle(.plain)
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
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(AppColor.cardBackground)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
            .appScrollEdgeSoftTop(enabled: true)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .appNavigationBarChrome()
            .tint(AppColor.accent)
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
