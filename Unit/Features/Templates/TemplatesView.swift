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
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @State private var showingOnboarding = false
    @State private var showingSettings = false

    private var activeSplit: Split? {
        splits.first
    }

    var body: some View {
        NavigationStack {
            AppScreen(
                showsNativeNavigationBar: true
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    if let split = activeSplit {
                        programContent(split: split)
                    } else {
                        emptyState
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: AppIcon.settingsOutline.systemName)
                    }
                }
            }
            .appNavigationBarChrome()
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
                        Text("No routines yet")
                            .font(AppFont.sectionHeader.font)
                            .foregroundStyle(AppColor.textPrimary)

                        Text("Finish your program setup to add training routines and exercises.")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            } else {
                Text("Routines")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.lg)
                    .padding(.leading, AppSpacing.md)

                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, template in
                            NavigationLink(value: template) {
                                RoutineRow(
                                    title: template.displayName,
                                    subtitle: routineSummary(for: template)
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
                    AppListRow(title: "Recent Sessions") {
                        EmptyView()
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Build your first program")
                .appFont(.largeTitle)
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

                    Text(displayName)
                        .appFont(.largeTitle)
                        .foregroundStyle(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !previewDays.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(Array(previewDays.enumerated()), id: \.element.id) { index, template in
                            ProgramDayPreviewRow(
                                title: template.displayName,
                                subtitle: routineSummary(for: template),
                                opacity: previewOpacity(for: index)
                            )
                        }
                    }
                }

                NavigationLink(value: split) {
                    Text("Edit program")
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
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

    private func routineSummary(for template: DayTemplate) -> String {
        let exerciseNames = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.displayName) })
        let count = template.orderedExerciseIds.compactMap { exerciseNames[$0] }.count
        if count == 0 {
            return "Add exercises"
        }
        return "\(count) exercise\(count == 1 ? "" : "s")"
    }
}

private struct RoutineRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        AppListRow(title: title, subtitle: subtitle) {
            EmptyView()
        }
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

    private var orderedTemplates: [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty {
            return linked
        }
        return templates.filter { $0.splitId == split.id }
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
                        Text("Routine Names")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)

                        if orderedTemplates.isEmpty {
                            Text("No routines in this program yet.")
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textSecondary)
                        } else {
                            ForEach(Array(orderedTemplates.enumerated()), id: \.element.id) { index, template in
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    TextField("Routine name", text: binding(for: template))
                                        .font(AppFont.body.font)
                                        .foregroundStyle(AppColor.textPrimary)
                                        .textInputAutocapitalization(.words)
                                        .frame(minHeight: 44)

                                    if index < orderedTemplates.count - 1 {
                                        AppDivider()
                                    }
                                }
                            }
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
