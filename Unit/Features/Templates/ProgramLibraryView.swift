//
//  ProgramLibraryView.swift
//  Unit
//
//  Browsable catalog of 8 starter programs filterable by level, goal, and
//  days-per-week. Tap a program to see its details and import.
//

import SwiftUI

/// Marker value used with `NavigationLink(value:)` to open the library.
struct ProgramLibraryDestination: Hashable {}

struct ProgramLibraryView: View {
    @State private var selectedLevel: ProgramTemplate.Level? = nil
    @State private var selectedGoal: ProgramTemplate.Goal? = nil
    @State private var selectedDays: Int? = nil

    private var filteredPrograms: [ProgramTemplate] {
        ProgramCatalog.all.filter { program in
            if let level = selectedLevel, program.level != level { return false }
            if let goal = selectedGoal, program.goal != goal { return false }
            if let days = selectedDays, program.daysPerWeek != days { return false }
            return true
        }
    }

    private var daysOptions: [Int] {
        Array(Set(ProgramCatalog.all.map(\.daysPerWeek))).sorted()
    }

    var body: some View {
        AppScreen(
            showsNativeNavigationBar: true
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                filterChips

                if filteredPrograms.isEmpty {
                    Text("No programs match these filters.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .appCardStyle()
                } else {
                    AppStackedCardList(filteredPrograms) { program in
                        NavigationLink(value: program) {
                            programRow(program)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Program Library")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: ProgramTemplate.self) { program in
            ProgramLibraryDetailView(program: program)
        }
        .appNavigationBarChrome()
        .appScrollEdgeSoft()
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(ProgramTemplate.Level.allCases, id: \.self) { level in
                    AppFilterChip(
                        label: level.displayName,
                        isSelected: selectedLevel == level,
                        showsClearGlyphWhenSelected: true
                    ) {
                        toggleLevel(level)
                    }
                }

                ForEach(ProgramTemplate.Goal.allCases, id: \.self) { goal in
                    AppFilterChip(
                        label: goal.displayName,
                        isSelected: selectedGoal == goal,
                        showsClearGlyphWhenSelected: true
                    ) {
                        toggleGoal(goal)
                    }
                }

                ForEach(daysOptions, id: \.self) { days in
                    AppFilterChip(
                        label: "\(days) days",
                        isSelected: selectedDays == days,
                        showsClearGlyphWhenSelected: true
                    ) {
                        toggleDays(days)
                    }
                }
            }
        }
    }

    private func programRow(_ program: ProgramTemplate) -> some View {
        PreviewListRow(
            title: program.name,
            subtitle: "\(program.level.displayName) · \(program.goal.displayName) · \(program.daysPerWeek) days/week"
        )
    }

    private func toggleLevel(_ level: ProgramTemplate.Level) {
        selectedLevel = selectedLevel == level ? nil : level
    }

    private func toggleGoal(_ goal: ProgramTemplate.Goal) {
        selectedGoal = selectedGoal == goal ? nil : goal
    }

    private func toggleDays(_ days: Int) {
        selectedDays = selectedDays == days ? nil : days
    }
}

