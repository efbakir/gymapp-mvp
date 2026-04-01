//
//  ProgramDetailView.swift
//  Unit
//
//  Program detail: routine day list, weeks section, and edit entry point.
//

import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    @Bindable var split: Split

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DayTemplate.name) private var allTemplates: [DayTemplate]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \Cycle.startDate, order: .reverse) private var allCycles: [Cycle]
    @Query private var progressionRules: [ProgressionRule]

    @State private var showingEdit = false

    private var orderedTemplates: [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: allTemplates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty { return linked }
        return allTemplates.filter { $0.splitId == split.id }
    }

    private var activeCycle: Cycle? {
        allCycles.first(where: { $0.splitId == split.id && !$0.isCompleted })
    }

    private var displayName: String {
        let trimmed = split.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Program" : trimmed
    }

    var body: some View {
        AppScreen(showsNativeNavigationBar: true) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                routineDaysCard

                if let cycle = activeCycle {
                    weeksSection(cycle: cycle)
                }
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingEdit = true } label: {
                    AppIcon.program.image(size: 17, weight: .semibold)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Edit program")
            }
        }
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $showingEdit) {
            EditProgramView(split: split)
        }
        .tint(AppColor.accent)
    }

    // MARK: - Routine Days

    private var routineDaysCard: some View {
        AppCard {
            AppDividedList(orderedTemplates) { template in
                let index = orderedTemplates.firstIndex(where: { $0.id == template.id }) ?? 0
                NavigationLink(value: template) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(template.displayName)
                            .font(AppFont.sectionHeader.font)
                            .foregroundStyle(AppColor.textPrimary)

                        Text(routineSubtitle(dayIndex: index, template: template))
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.vertical, AppSpacing.smd)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Weeks

    private enum WeekStatus {
        case completed, current, upcoming
    }

    private struct WeekRowData: Identifiable {
        var id: Int { weekNumber }
        let weekNumber: Int
        let status: WeekStatus
        let dayCompletions: [Bool]
    }

    @ViewBuilder
    private func weeksSection(cycle: Cycle) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.smd) {
            Text("Weeks")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, AppSpacing.xs)

            AppCard {
                AppDividedList(weekRows(for: cycle)) { row in
                    weekRowView(row, cycle: cycle)
                }
            }
        }
    }

    private func weekRows(for cycle: Cycle) -> [WeekRowData] {
        let currentWeek = cycle.currentWeekNumber
        return (1...cycle.weekCount).map { week in
            let status: WeekStatus
            if week < currentWeek { status = .completed }
            else if week == currentWeek { status = .current }
            else { status = .upcoming }

            let completions: [Bool]
            if status == .completed || status == .current {
                let weekSessions = sessions.filter {
                    $0.cycleId == cycle.id && $0.weekNumber == week && $0.isCompleted
                }
                let completedIds = Set(weekSessions.map(\.templateId))
                completions = orderedTemplates.map { completedIds.contains($0.id) }
            } else {
                completions = []
            }

            return WeekRowData(weekNumber: week, status: status, dayCompletions: completions)
        }
    }

    @ViewBuilder
    private func weekRowView(_ row: WeekRowData, cycle: Cycle) -> some View {
        let isNavigable = row.status == .completed || row.status == .current

        let content = HStack {
            Text("Week \(row.weekNumber)")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(row.status == .upcoming ? AppColor.textSecondary : AppColor.textPrimary)

            Spacer()

            if row.status == .current {
                AppTag(text: "Current")
            } else if row.status == .completed {
                dayCompletionIndicators(row.dayCompletions)
            }
        }
        .padding(.vertical, AppSpacing.smd)
        .frame(minHeight: 44)
        .contentShape(Rectangle())

        if isNavigable {
            NavigationLink {
                WeekDetailView(
                    cycle: cycle,
                    weekNumber: row.weekNumber,
                    rules: progressionRules,
                    exercises: exercises,
                    sessions: sessions
                )
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private func dayCompletionIndicators(_ completions: [Bool]) -> some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(Array(completions.enumerated()), id: \.offset) { _, completed in
                ZStack {
                    Circle()
                        .fill(AppColor.mutedFill)
                        .frame(width: 20, height: 20)

                    if completed {
                        AppIcon.checkmark.image(size: 10, weight: .bold)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func routineSubtitle(dayIndex: Int, template: DayTemplate) -> String {
        let count = template.orderedExerciseIds.count
        let label = count == 0 ? "Add exercises" : "\(count) exercise\(count == 1 ? "" : "s")"
        return "Day \(dayIndex + 1) · \(label)"
    }
}

#Preview {
    NavigationStack {
        let container = PreviewSampleData.makePreviewContainer()
        let split = (try? container.mainContext.fetch(FetchDescriptor<Split>()))?.first

        Group {
            if let split {
                ProgramDetailView(split: split)
                    .modelContainer(container)
            }
        }
    }
}
