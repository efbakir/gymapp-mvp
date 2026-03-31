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
    // Cycle query removed — cycles are deferred to post-v1 (compass 2026-03-26).

    @State private var showingOnboarding = false
    @State private var showingSettings = false

    private var activeSplit: Split? {
        splits.first
    }

    private var inactiveSplits: [Split] {
        Array(splits.dropFirst())
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
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: AppIcon.settingsOutline.systemName)
                    }
                    .accessibilityLabel("Settings")
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
            // MARK: Active Program section
            Text("Active Program")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.leading, AppSpacing.md)

            activeProgramCard(split: split, days: days)

            // MARK: Recent Sessions
            NavigationLink {
                RecentSessionsView(showsCloseButton: false)
            } label: {
                Text("Recent Sessions")
                    .font(AppFont.label.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColor.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            }
            .buttonStyle(.plain)

            // MARK: All Programs (inactive splits)
            if !inactiveSplits.isEmpty {
                Text("All Programs")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.md)
                    .padding(.leading, AppSpacing.md)

                AppCard {
                    AppDividedList(inactiveSplits) { split in
                        let splitDays = orderedTemplates(for: split)
                        let dayCount = splitDays.count
                        let exerciseCount = splitDays.reduce(0) { $0 + $1.orderedExerciseIds.count }
                        PreviewListRow(
                            title: split.name.isEmpty ? "Untitled Program" : split.name,
                            subtitle: "\(dayCount) day\(dayCount == 1 ? "" : "s") · \(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
                        )
                    }
                }
            }
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

        return AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text(displayName)
                    .appFont(.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !days.isEmpty {
                    PreviewListContainer {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, template in
                            NavigationLink(value: template) {
                                PreviewListRow(
                                    title: template.displayName,
                                    subtitle: routineSummary(for: template)
                                )
                            }
                            .buttonStyle(.plain)
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
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Program Name")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.leading, AppSpacing.xs)

                    TextField("Program name", text: $split.name)
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .textInputAutocapitalization(.words)
                        .appInputFieldStyle()
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Routines")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.leading, AppSpacing.xs)

                    if orderedTemplates.isEmpty {
                        Text("No routines in this program yet.")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(AppSpacing.md)
                    } else {
                        VStack(spacing: AppSpacing.sm) {
                            ForEach(orderedTemplates, id: \.id) { template in
                                TextField("Routine name", text: binding(for: template))
                                    .font(AppFont.body.font)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .textInputAutocapitalization(.words)
                                    .appInputFieldStyle()
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
