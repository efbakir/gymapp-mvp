//
//  OnboardingExercisesView.swift
//  Unit
//
//  Screen 5 — Add exercises per training day.
//  Search or type to add. Minimum 1 exercise per day.
//

import SwiftUI
import UniformTypeIdentifiers

struct OnboardingExercisesView: View {
    @Environment(OnboardingViewModel.self) private var vm
    var progressStep: Int
    var progressTotal: Int
    var onContinue: () -> Void

    @State private var selectedDayIndex: Int = 0
    @State private var showingAddSheet: Bool = false
    @FocusState private var focusedExerciseID: UUID?
    @State private var draggedExerciseID: UUID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func exerciseNameBinding(dayIndex: Int, exerciseID: UUID) -> Binding<String> {
        Binding(
            get: {
                guard vm.dayExercises.indices.contains(dayIndex),
                      let i = vm.dayExercises[dayIndex].firstIndex(where: { $0.id == exerciseID }) else {
                    return ""
                }
                return vm.dayExercises[dayIndex][i].name
            },
            set: { newValue in
                guard vm.dayExercises.indices.contains(dayIndex),
                      let i = vm.dayExercises[dayIndex].firstIndex(where: { $0.id == exerciseID }) else {
                    return
                }
                vm.dayExercises[dayIndex][i].name = newValue
            }
        )
    }

    var body: some View {
        @Bindable var vm = vm

        OnboardingShell(
            title: "Add exercises",
            ctaLabel: "Create my program",
            ctaEnabled: vm.exercisesAreValid,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue,
            content: {
                let dayExs = vm.dayExercises.indices.contains(selectedDayIndex) ? vm.dayExercises[selectedDayIndex] : []

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    if !dayExs.isEmpty {
                        AppCardList(dayExs) { ex in
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                HStack {
                                    AppIcon.reorder.image(size: 15, weight: .semibold)
                                        .foregroundStyle(AppColor.textSecondary)
                                        .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .onDrag {
                                            draggedExerciseID = ex.id
                                            return NSItemProvider(object: ex.id.uuidString as NSString)
                                        }

                                    TextField("Exercise name", text: exerciseNameBinding(dayIndex: selectedDayIndex, exerciseID: ex.id))
                                        .font(AppFont.body.font)
                                        .foregroundStyle(AppColor.textPrimary)
                                        .focused($focusedExerciseID, equals: ex.id)
                                        .textInputAutocapitalization(.words)
                                        .autocorrectionDisabled()
                                        .submitLabel(.done)
                                    Spacer()
                                    Button {
                                        vm.dayExercises[selectedDayIndex].removeAll { $0.id == ex.id }
                                        vm.baselines.removeValue(forKey: ex.id)
                                        if focusedExerciseID == ex.id {
                                            focusedExerciseID = nil
                                        }
                                    } label: {
                                        AppIcon.close.image(size: 15, weight: .semibold)
                                            .foregroundStyle(AppColor.textSecondary)
                                            .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                                            .contentShape(Rectangle())
                                    }
                                }
                                .frame(height: 48)

                                HStack(spacing: AppSpacing.md) {
                                    plannedStepper(
                                        label: "Sets",
                                        value: ex.plannedSets,
                                        onDecrement: { vm.adjustPlannedSets(dayIndex: selectedDayIndex, exerciseId: ex.id, delta: -1) },
                                        onIncrement: { vm.adjustPlannedSets(dayIndex: selectedDayIndex, exerciseId: ex.id, delta: 1) }
                                    )
                                    plannedStepper(
                                        label: "Reps",
                                        value: ex.plannedReps,
                                        onDecrement: { vm.adjustPlannedReps(dayIndex: selectedDayIndex, exerciseId: ex.id, delta: -1) },
                                        onIncrement: { vm.adjustPlannedReps(dayIndex: selectedDayIndex, exerciseId: ex.id, delta: 1) }
                                    )
                                    Spacer(minLength: 0)
                                }
                                .padding(.leading, AppSpacing.xxl)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                focusedExerciseID = ex.id
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: ExerciseReorderDropDelegate(
                                    targetExerciseID: ex.id,
                                    exercises: $vm.dayExercises[selectedDayIndex],
                                    draggedExerciseID: $draggedExerciseID,
                                    reduceMotion: reduceMotion
                                )
                            )
                        }
                    }

                    AppGhostButton("Add exercise") {
                        showingAddSheet = true
                    }
                }
            },
            stickyAccessory: {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<vm.dayCount, id: \.self) { i in
                            AppFilterChip(
                                label: vm.dayNames[i],
                                isSelected: selectedDayIndex == i,
                                showsTrailingDot: vm.dayExercises[i].isEmpty
                            ) {
                                selectedDayIndex = i
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.xs / 2)
                }
                .appScrollEdgeSoft()
            }
        )
        .sheet(isPresented: $showingAddSheet, onDismiss: {
            focusedExerciseID = nil
        }) {
            ExerciseSearchSheet(dayIndex: selectedDayIndex)
                .environment(vm)
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .onChange(of: selectedDayIndex) { _, _ in
            focusedExerciseID = nil
            draggedExerciseID = nil
        }
        .onChange(of: vm.dayCount) { _, newValue in
            if selectedDayIndex >= newValue {
                selectedDayIndex = max(0, newValue - 1)
            }
            focusedExerciseID = nil
            draggedExerciseID = nil
        }
    }

    @ViewBuilder
    private func plannedStepper(
        label: String,
        value: Int,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(label)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
            AppStepper(
                value: "\(value)",
                onDecrement: onDecrement,
                onIncrement: onIncrement
            )
        }
    }
}

private struct ExerciseReorderDropDelegate: DropDelegate {
    let targetExerciseID: UUID
    @Binding var exercises: [OnboardingExercise]
    @Binding var draggedExerciseID: UUID?
    var reduceMotion: Bool = false

    func dropEntered(info: DropInfo) {
        guard let draggedExerciseID,
              draggedExerciseID != targetExerciseID,
              let fromIndex = exercises.firstIndex(where: { $0.id == draggedExerciseID }),
              let toIndex = exercises.firstIndex(where: { $0.id == targetExerciseID }) else {
            return
        }

        withAnimation(reduceMotion ? nil : .spring(response: 0.22, dampingFraction: 0.9)) {
            let movedExercise = exercises.remove(at: fromIndex)
            exercises.insert(movedExercise, at: toIndex)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedExerciseID = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// MARK: - Exercise Search Sheet

struct ExerciseSearchSheet: View {
    @Environment(OnboardingViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    let dayIndex: Int

    @State private var query: String = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredSuggestions: [String] {
        let existing = vm.dayExercises[dayIndex].map { $0.name.lowercased() }
        return ExerciseLibrary.filtered(by: query).filter { !existing.contains($0.lowercased()) }
    }

    private var showCustomOption: Bool {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return false }
        return !ExerciseLibrary.suggestions.contains(where: { $0.lowercased() == q.lowercased() })
            && !vm.dayExercises[dayIndex].contains(where: { $0.name.lowercased() == q.lowercased() })
    }

    var body: some View {
        NavigationStack {
            List {
                if showCustomOption {
                    let trimmed = query.trimmingCharacters(in: .whitespaces)
                    Button {
                        addExercise(name: trimmed)
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            AppIcon.addCircle.image()
                                .foregroundStyle(AppColor.accent)
                            Text("Add \"\(trimmed)\"")
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textPrimary)
                        }
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .listRowBackground(AppColor.cardBackground)
                }

                ForEach(filteredSuggestions, id: \.self) { name in
                    Button {
                        addExercise(name: name)
                    } label: {
                        Text(name)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(minHeight: 44, alignment: .leading)
                    }
                    .listRowBackground(AppColor.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.sheetBackground.ignoresSafeArea())
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search or type exercise name")
            .searchFocused($isSearchFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .onSubmit(of: .search) {
                let trimmed = query.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                addExercise(name: trimmed)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .appToolbarTextStyle()
                }
            }
            .appNavigationBarChrome()
            .tint(AppColor.systemTint)
            .onAppear { isSearchFocused = true }
        }
    }

    private func addExercise(name: String) {
        let ex = OnboardingExercise(name: name)
        vm.dayExercises[dayIndex].append(ex)
        query = ""
        dismiss()
    }
}

#Preview {
    NavigationStack {
        OnboardingExercisesView(progressStep: 3, progressTotal: 6) { }
            .environment({
                let vm = OnboardingViewModel()
                vm.seedSampleData()
                return vm
            }())
    }
    .tint(AppColor.systemTint)
}
