//
//  TemplatesView.swift
//  Unit
//
//  Program root: one active program, day list, and narrow edit surfaces.
//

import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \Cycle.startDate, order: .reverse) private var cycles: [Cycle]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @State private var showingOnboarding = false
    @State private var showingSettings = false

    private var activeCycle: Cycle? {
        cycles.first(where: { $0.isActive && !$0.isCompleted })
            ?? cycles.first(where: { !$0.isCompleted })
    }

    private var activeSplit: Split? {
        if let splitID = activeCycle?.splitId {
            return splits.first(where: { $0.id == splitID }) ?? splits.first
        }
        return splits.first
    }

    var body: some View {
        NavigationStack {
            AppScreen(
                title: nil,
                customHeader: ProductTopBar(
                    title: "Program",
                    trailingActions: [
                        .icon(.settingsOutline) {
                            showingSettings = true
                        }
                    ]
                ).eraseToAnyView(),
                navigationBarTitleDisplayMode: .inline
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    if let split = activeSplit {
                        programContent(split: split)
                    } else {
                        emptyState
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Split.self) { split in
                EditProgramView(split: split)
            }
            .navigationDestination(for: DayTemplate.self) { template in
                TemplateDetailView(template: template)
            }
            .navigationDestination(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                }
                .appBottomSheetChrome()
            }
            .tint(AppColor.accent)
        }
    }

    @ViewBuilder
    private func programContent(split: Split) -> some View {
        let days = orderedTemplates(for: split)

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            activeProgramCard(split: split, days: days)

            if days.isEmpty {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("No days yet")
                            .font(AppFont.sectionHeader.font)
                            .foregroundStyle(AppColor.textPrimary)

                        Text("Finish your program setup to add training days and exercises.")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            } else {
                Text("Days")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.lg)
                    .padding(.leading, AppSpacing.md)

                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, template in
                            NavigationLink(value: template) {
                                ProgramDayGroupRow(
                                    title: template.name,
                                    subtitle: daySummary(for: template)
                                )
                            }
                            .buttonStyle(.plain)

                            if index < days.count - 1 {
                                AppDivider()
                            }
                        }
                    }
                }
            }

            Text("History")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, AppSpacing.lg)
                .padding(.leading, AppSpacing.md)

            NavigationLink {
                RecentSessionsView(showsCloseButton: false)
            } label: {
                AppCard {
                    AppListRow(title: "Recent Sessions")
                }
            }
            .buttonStyle(.plain)

            NavigationLink {
                CyclesView()
            } label: {
                AppCard {
                    AppListRow(title: "Cycle Timeline")
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Build your first program")
                .font(AppFont.largeTitle.font)
                .foregroundStyle(AppColor.textPrimary)

            Text("Add your training days, exercises, and starting weights so Unit can prepare the next target.")
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(3)

            AppPrimaryButton("Create Program") {
                showingOnboarding = true
            }
        }
        .appCardStyle()
    }

    private func activeProgramCard(split: Split, days: [DayTemplate]) -> some View {
        let displayName = split.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Program"
            : split.name
        let previewDays = Array(days.prefix(3))

        return AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(AppColor.success)
                            .frame(width: 6, height: 6)

                        Text("Active Program")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.success)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(displayName)
                            .font(AppFont.largeTitle.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: AppSpacing.sm) {
                            Text(programWeekLabel)
                                .font(AppFont.caption.font)
                                .foregroundStyle(AppColor.textSecondary)

                            Text(programDayCountLabel(dayCount: days.count))
                                .font(AppFont.caption.font)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }

                if !previewDays.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(Array(previewDays.enumerated()), id: \.element.id) { index, template in
                            ProgramDayPreviewRow(
                                title: template.name,
                                subtitle: daySummary(for: template),
                                opacity: previewOpacity(for: index)
                            )
                        }
                    }
                }

                NavigationLink(value: split) {
                    Text("Edit program")
                        .font(AppFont.label.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var programWeekLabel: String {
        guard let activeCycle else { return "No active cycle" }
        return "Week \(activeCycle.currentWeekNumber) of \(activeCycle.weekCount)"
    }

    private func programDayCountLabel(dayCount: Int) -> String {
        "\(dayCount) Day\(dayCount == 1 ? "" : "s")"
    }

    private func previewOpacity(for index: Int) -> Double {
        switch index {
        case 0: return 1
        case 1: return 0.6
        default: return 0.2
        }
    }

    private func orderedTemplates(for split: Split) -> [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty {
            return linked
        }
        return templates.filter { $0.splitId == split.id }
    }

    private func daySummary(for template: DayTemplate) -> String {
        let exerciseNames = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.displayName) })
        let count = template.orderedExerciseIds.compactMap { exerciseNames[$0] }.count
        if count == 0 {
            return "Add exercises"
        }
        return "\(count) exercise\(count == 1 ? "" : "s")"
    }
}

private struct ProgramDayGroupRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        AppListRow(title: title, subtitle: subtitle)
    }
}

private struct ProgramDayPreviewRow: View {
    let title: String
    let subtitle: String
    let opacity: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.vertical, AppSpacing.sm)
        .opacity(opacity)
    }
}

struct EditProgramView: View {
    @Bindable var split: Split

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Cycle.startDate, order: .reverse) private var cycles: [Cycle]

    private var orderedTemplates: [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty {
            return linked
        }
        return templates.filter { $0.splitId == split.id }
    }

    private var activeCycle: Cycle? {
        cycles.first(where: { $0.isActive && !$0.isCompleted && $0.splitId == split.id })
            ?? cycles.first(where: { !$0.isCompleted && $0.splitId == split.id })
    }

    var body: some View {
        AppScreen(
            title: "Edit Program",
            trailingText: NavTextAction(label: "Done", action: { dismiss() })
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Program Name")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)

                        TextField("Program name", text: $split.name)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .textInputAutocapitalization(.words)
                            .frame(minHeight: 44)
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Day Names")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)

                        if orderedTemplates.isEmpty {
                            Text("No days in this program yet.")
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textSecondary)
                        } else {
                            ForEach(Array(orderedTemplates.enumerated()), id: \.element.id) { index, template in
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    HStack(spacing: AppSpacing.sm) {
                                        Text("Day \(index + 1)")
                                            .font(AppFont.caption.font)
                                            .foregroundStyle(AppColor.textSecondary)
                                            .frame(width: 44, alignment: .leading)

                                        TextField("Day name", text: binding(for: template))
                                            .font(AppFont.body.font)
                                            .foregroundStyle(AppColor.textPrimary)
                                            .textInputAutocapitalization(.words)
                                            .frame(minHeight: 44)
                                    }

                                    if index < orderedTemplates.count - 1 {
                                        AppDivider()
                                    }
                                }
                            }
                        }
                    }
                }

                if let activeCycle {
                    AppCard {
                        AppListRow(title: "Weekly Increase") {
                            AppStepper(
                                value: "\(activeCycle.globalIncrementKg.weightString) kg",
                                minimumValueWidth: 64,
                                onDecrement: {
                                    activeCycle.globalIncrementKg = max(0, activeCycle.globalIncrementKg - 0.5)
                                    try? modelContext.save()
                                },
                                onIncrement: {
                                    activeCycle.globalIncrementKg += 0.5
                                    try? modelContext.save()
                                }
                            )
                        }
                    }
                }
            }
        }
        .onChange(of: split.name) { _, _ in
            try? modelContext.save()
        }
        .onAppear {
            syncTemplateOrderIfNeeded()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func binding(for template: DayTemplate) -> Binding<String> {
        Binding(
            get: { template.name },
            set: { newValue in
                template.name = newValue
                try? modelContext.save()
            }
        )
    }

    private func syncTemplateOrderIfNeeded() {
        if split.orderedTemplateIds.isEmpty {
            split.orderedTemplateIds = templates
                .filter { $0.splitId == split.id }
                .map(\.id)
            try? modelContext.save()
        }
    }
}

#Preview {
    TemplatesView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
