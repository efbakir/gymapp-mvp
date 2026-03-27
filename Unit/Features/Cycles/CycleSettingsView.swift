//
//  CycleSettingsView.swift
//  Unit
//
//  Settings sheet for an active cycle: increment, auto-deload, name, danger zone.
//

import SwiftUI
import SwiftData

struct CycleSettingsView: View {
    @Bindable var cycle: Cycle

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var rules: [ProgressionRule]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @State private var showingResetConfirm = false

    private var cycleRules: [ProgressionRule] {
        rules.filter { $0.cycleId == cycle.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cycle Name") {
                    TextField("Name", text: $cycle.name)
                        .frame(minHeight: 44)
                }
                .listRowBackground(AppColor.cardBackground)

                Section("Defaults") {
                    Stepper(
                        value: $cycle.globalIncrementKg,
                        in: 0.5...10.0,
                        step: 0.5
                    ) {
                        HStack {
                            Text("Global Increment")
                            Spacer()
                            Text("\(WorkoutTargetFormatter.weightDisplay(cycle.globalIncrementKg))/week")
                                .foregroundStyle(AppColor.accent)
                                .monospacedDigit()
                        }
                    }
                    .frame(minHeight: 44)
                }
                .listRowBackground(AppColor.cardBackground)

                if !cycleRules.isEmpty {
                    Section {
                        ForEach(cycleRules, id: \.id) { rule in
                            ExerciseWeightRow(
                                rule: rule,
                                cycle: cycle,
                                sessions: Array(sessions),
                                exerciseName: exercises.first(where: { $0.id == rule.exerciseId })?.displayName ?? "Exercise"
                            )
                        }
                    } header: {
                        Text("Exercise Base Weights")
                    } footer: {
                        Text("Changing base weight recalculates all future week targets.")
                    }
                    .listRowBackground(AppColor.cardBackground)
                }

                Section("Danger Zone") {
                    Button(role: .destructive) {
                        showingResetConfirm = true
                    } label: {
                        Label("Reset Cycle", systemImage: "arrow.counterclockwise.circle")
                            .frame(minHeight: 44)
                    }
                    .confirmationDialog(
                        "Reset Cycle",
                        isPresented: $showingResetConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Reset — Erase All Progress", role: .destructive) {
                            resetCycle()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This resets all failure counts and deload flags. Logged sessions are preserved.")
                    }
                }
                .listRowBackground(AppColor.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
            .appScrollEdgeSoftTop(enabled: true)
            .navigationTitle("Cycle Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .appNavigationBarChrome()
        }
    }

    private func resetCycle() {
        for rule in cycleRules {
            rule.consecutiveFailures = 0
            rule.isDeloaded = false
        }
        try? modelContext.save()
        dismiss()
    }

}

// MARK: - Exercise Weight Row

private struct ExerciseWeightRow: View {
    @Bindable var rule: ProgressionRule
    let cycle: Cycle
    let sessions: [WorkoutSession]
    let exerciseName: String

    // The next planned weight for the current (or next) week
    private var nextWeight: Double {
        let weekNum = max(cycle.currentWeekNumber, 1)
        let snapshot = rule.snapshot(weekCount: cycle.weekCount)
        let outcomes = rule.buildOutcomes(from: sessions)
        return ProgressionEngine.target(for: weekNum, rule: snapshot, outcomes: outcomes)?.weightKg ?? rule.baseWeightKg
    }

    // What the weight was before the current base (simulated with base - increment)
    private var previousWeight: Double {
        rule.baseWeightKg - rule.incrementKg
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(exerciseName)
                .font(AppFont.body.font)

            Stepper(
                value: $rule.baseWeightKg,
                in: 0...500,
                step: 2.5
            ) {
                HStack {
                    Text("Base")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    Text(WorkoutTargetFormatter.weightDisplay(rule.baseWeightKg))
                        .font(AppFont.body.font)
                        .monospacedDigit()
                }
            }
            .frame(minHeight: 44)

            // Inline preview
            Text("Next target: \(WorkoutTargetFormatter.weightDisplay(nextWeight))  ·  was \(WorkoutTargetFormatter.weightDisplay(previousWeight))")
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.accent)
                .monospacedDigit()
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
