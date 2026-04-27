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

    private func exerciseNameBinding(dayIndex: Int, exerciseIndex: Int) -> Binding<String> {
        Binding(
            get: {
                guard vm.dayExercises.indices.contains(dayIndex),
                      vm.dayExercises[dayIndex].indices.contains(exerciseIndex) else {
                    return ""
                }
                return vm.dayExercises[dayIndex][exerciseIndex].name
            },
            set: { newValue in
                guard vm.dayExercises.indices.contains(dayIndex),
                      vm.dayExercises[dayIndex].indices.contains(exerciseIndex) else {
                    return
                }
                vm.dayExercises[dayIndex][exerciseIndex].name = newValue
            }
        )
    }

    var body: some View {
        @Bindable var vm = vm

        OnboardingShell(
            title: "Add exercises",
            ctaLabel: "Create My Program",
            ctaEnabled: vm.exercisesAreValid,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {

                // Day tab strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<vm.dayCount, id: \.self) { i in
                            OnboardingDayChip(
                                name: vm.dayNames[i],
                                isSelected: selectedDayIndex == i,
                                showsDot: vm.dayExercises[i].isEmpty
                            ) {
                                selectedDayIndex = i
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.xs / 2)
                }

                // Exercise list for selected day
                let dayExs = vm.dayExercises.indices.contains(selectedDayIndex) ? vm.dayExercises[selectedDayIndex] : []

                if !dayExs.isEmpty {
                    VStack(spacing: AppSpacing.xs) {
                        ForEach(Array(dayExs.enumerated()), id: \.element.id) { exerciseIndex, ex in
                            HStack {
                                AppIcon.reorder.image(size: 14, weight: .semibold)
                                    .foregroundStyle(AppColor.textSecondary)
                                    .frame(width: 20, height: 20)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .contentShape(Rectangle())
                                    .onDrag {
                                        draggedExerciseID = ex.id
                                        return NSItemProvider(object: ex.id.uuidString as NSString)
                                    }

                                TextField("Exercise name", text: exerciseNameBinding(dayIndex: selectedDayIndex, exerciseIndex: exerciseIndex))
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
                                    AppIcon.close.image(size: 12, weight: .semibold)
                                        .foregroundStyle(AppColor.textSecondary)
                                        .frame(minWidth: 44, minHeight: 44)
                                        .contentShape(Rectangle())
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .frame(height: 48)
                            .background(AppColor.cardBackground)
                            .contentShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColor.accent.opacity(focusedExerciseID == ex.id ? 0.5 : 0), lineWidth: 1.5)
                                    .animation(.easeOut(duration: 0.18), value: focusedExerciseID == ex.id)
                            )
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
                }

                AppGhostButton("Add exercise") {
                    showingAddSheet = true
                }
            }
        }
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
        ZStack {
            AppColor.cardBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: AppSpacing.sm) {
                    AppIcon.search.image()
                        .foregroundStyle(AppColor.textSecondary)
                    TextField("Search or type exercise name", text: $query)
                        .focused($isSearchFocused)
                        .foregroundStyle(AppColor.textPrimary)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            let trimmed = query.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty { addExercise(name: trimmed) }
                        }
                    if !query.isEmpty {
                        Button { query = "" } label: {
                            AppIcon.xmarkFilled.image()
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
                .padding(AppSpacing.sm)
                .background(AppColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .padding(AppSpacing.md)

                AppDivider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Custom entry option
                        if showCustomOption {
                            let trimmed = query.trimmingCharacters(in: .whitespaces)
                            Button {
                                addExercise(name: trimmed)
                            } label: {
                                HStack {
                                    AppIcon.addCircle.image()
                                        .foregroundStyle(AppColor.accent)
                                    Text("Add \"\(trimmed)\"")
                                        .font(AppFont.body.font)
                                        .foregroundStyle(AppColor.textPrimary)
                                }
                                .padding(.horizontal, AppSpacing.md)
                                .frame(height: 48)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(ScaleButtonStyle())

                            AppDivider()
                                .padding(.horizontal, AppSpacing.md)
                        }

                        // Library suggestions
                        ForEach(filteredSuggestions, id: \.self) { name in
                            Button {
                                addExercise(name: name)
                            } label: {
                                Text(name)
                                    .font(AppFont.body.font)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, AppSpacing.md)
                                    .frame(height: 48)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(ScaleButtonStyle())

                            AppDivider()
                                .padding(.horizontal, AppSpacing.md)
                        }
                    }
                }
            }
        }
        .onAppear { isSearchFocused = true }
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
