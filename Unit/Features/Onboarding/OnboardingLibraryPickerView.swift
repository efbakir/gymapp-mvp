//
//  OnboardingLibraryPickerView.swift
//  Unit
//
//  Library path's first screen (Phase B-3). Shows the full starter-program
//  catalog (`ProgramCatalog.all`, the same list the in-app program library
//  renders) with the same Level / Goal / Days filters as the in-app library.
//  Programs use the canonical selectable-card treatment so a returning step
//  can show the saved choice and hand navigation to the sticky Continue CTA.
//
//  No manual-build escape hatch on this screen. If the user wants a program
//  not on this list, they take the Paste path from `OnboardingImportMethodView`.
//

import SwiftUI

struct OnboardingLibraryPickerView: View {
    var progressStep: Int
    var progressTotal: Int
    var selectedProgramID: UUID?
    var onPick: (ProgramTemplate) -> Void
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var selectedLevel: ProgramTemplate.Level? = nil
    @State private var selectedGoal: ProgramTemplate.Goal? = nil
    @State private var selectedDays: Int? = nil

    private var programs: [ProgramTemplate] { ProgramCatalog.all }

    private var filteredPrograms: [ProgramTemplate] {
        programs.filter { program in
            if let level = selectedLevel, program.level != level { return false }
            if let goal = selectedGoal, program.goal != goal { return false }
            if let days = selectedDays, program.daysPerWeek != days { return false }
            return true
        }
    }

    private var daysOptions: [Int] {
        Array(Set(programs.map(\.daysPerWeek))).sorted()
    }

    var body: some View {
        OnboardingShell(
            title: AppCopy.Onboarding.libraryTitle,
            subtitle: AppCopy.Onboarding.librarySubtitle,
            ctaEnabled: selectedProgramID != nil,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue,
            onBack: onBack
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                filterBar

                if filteredPrograms.isEmpty {
                    AppEmptyHint("No programs match these filters.")
                } else {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(filteredPrograms) { program in
                            AppOptionTileCard(
                                title: program.name,
                                subtitle: "\(program.level.displayName) · \(program.goal.displayName) · \(program.daysPerWeek) days/week",
                                isSelected: selectedProgramID == program.id
                            ) {
                                onPick(program)
                            }
                        }
                    }
                }
            }
        }
    }

    // Mirrors ProgramLibraryView.filterBar — same dropdown-chip filter so the
    // two program surfaces stay consistent (CLAUDE.md §4 reuse rule).
    private var filterBar: some View {
        AppFilterChipBar {
            AppDropdownChip(
                label: selectedLevel?.displayName ?? "Level",
                isActive: selectedLevel != nil
            ) {
                Picker("Level", selection: $selectedLevel) {
                    Text("All").tag(ProgramTemplate.Level?.none)
                    ForEach(ProgramTemplate.Level.allCases) { level in
                        Text(level.displayName).tag(Optional(level))
                    }
                }
            }

            AppDropdownChip(
                label: selectedGoal?.displayName ?? "Goal",
                isActive: selectedGoal != nil
            ) {
                Picker("Goal", selection: $selectedGoal) {
                    Text("All").tag(ProgramTemplate.Goal?.none)
                    ForEach(ProgramTemplate.Goal.allCases) { goal in
                        Text(goal.displayName).tag(Optional(goal))
                    }
                }
            }

            AppDropdownChip(
                label: selectedDays.map { "\($0) days" } ?? "Days/week",
                isActive: selectedDays != nil
            ) {
                Picker("Days/week", selection: $selectedDays) {
                    Text("All").tag(Int?.none)
                    ForEach(daysOptions, id: \.self) { days in
                        Text("\(days) days").tag(Optional(days))
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingLibraryPickerView(
            progressStep: 3,
            progressTotal: 5,
            selectedProgramID: ProgramCatalog.all.first?.id,
            onPick: { _ in },
            onContinue: {},
            onBack: {}
        )
    }
}
