//
//  TemplatesView.swift
//  Unit
//
//  Program root: one active program, day list, and narrow edit surfaces.
//

import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTabSelection) private var appTabSelection

    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @AppStorage(ActiveSplitStore.defaultsKey) private var activeSplitIdString: String = ""

    @State private var showingOnboarding = false
    @State private var showingSettings = false

    private var activeSplit: Split? {
        ActiveSplitStore.resolve(from: splits)
    }

    private var inactiveSplits: [Split] {
        guard let active = activeSplit else { return [] }
        return splits.filter { $0.id != active.id }
    }

    var body: some View {
        NavigationStack {
            AppScreen(
                showsNativeNavigationBar: true,
                usesOuterScroll: false
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
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: ProgramLibraryDestination()) {
                        Text("Browse")
                            .appToolbarTextStyle()
                    }
                    .accessibilityLabel("Browse Program Library")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: AppIcon.settingsOutline.systemName)
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .appNavigationBarChrome()
            .navigationDestination(for: Split.self) { split in
                ProgramDetailView(split: split)
            }
            .navigationDestination(for: DayTemplate.self) { template in
                TemplateDetailView(template: template)
            }
            .navigationDestination(for: ProgramLibraryDestination.self) { _ in
                ProgramLibraryView()
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
            .onAppear {
                QuickStartSupport.cleanupOrphanedTemplates(
                    modelContext: modelContext,
                    templates: templates,
                    sessions: sessions
                )
            }
        }
    }

    @ViewBuilder
    private func programContent(split: Split) -> some View {
        let days = orderedTemplates(for: split)

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            activeProgramCard(split: split, days: days)

            Button {
                QuickStartSupport.startEmptyWorkout(modelContext: modelContext, activeSplit: split)
                appTabSelection(.today)
            } label: {
                AppGhostButtonLabel(title: AppCopy.Workout.freestyleSession)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, AppSpacing.xxs)
            .accessibilityLabel("Freestyle session, log without a program day")

            // MARK: All Programs (inactive splits)
            if !inactiveSplits.isEmpty {
                AppSectionHeader("All Programs")
                    .padding(.top, AppSpacing.md)

                AppCardList(inactiveSplits) { split in
                    let splitDays = orderedTemplates(for: split)
                    let dayCount = splitDays.count
                    let exerciseCount = splitDays.reduce(0) { $0 + $1.orderedExerciseIds.count }
                    NavigationLink(value: split) {
                        PreviewListRow(
                            title: split.name.isEmpty ? "Untitled Program" : split.name,
                            subtitle: "\(dayCount) day\(dayCount == 1 ? "" : "s") · \(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Build your first program")
                    .appFont(.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Add your training days, exercises, and starting weights so Unit can prepare the next target.")
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
            }

            VStack(spacing: AppSpacing.xs) {
                AppPrimaryButton("Create Program") {
                    showingOnboarding = true
                }

                NavigationLink(value: ProgramLibraryDestination()) {
                    AppGhostButtonLabel(title: "Pick a starter program")
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .appCardStyle()
    }

    private func activeProgramCard(split: Split, days: [DayTemplate]) -> some View {
        let displayName = split.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Program"
            : split.name

        return AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                NavigationLink(value: split) {
                    HStack(alignment: .center, spacing: AppSpacing.sm) {
                        Text(displayName)
                            .font(AppFont.largeTitle.font)
                            .tracking(AppFont.largeTitle.tracking)
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        AppTag(text: "Active", style: .muted, layout: .compactCapsule)

                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(displayName), active program")
                    .accessibilityHint("Opens program details")
                }
                .buttonStyle(ScaleButtonStyle())

                if !days.isEmpty {
                    PreviewListContainer {
                        ForEach(days, id: \.id) { template in
                            NavigationLink(value: template) {
                                PreviewListRow(
                                    title: template.displayName,
                                    subtitle: routineSummary(for: template)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
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

    @State private var showDeleteConfirmation = false
    @State private var showAddDay = false
    @State private var isReordering = false

    private var orderedTemplates: [DayTemplate] {
        let byID = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        let linked = split.orderedTemplateIds.compactMap { byID[$0] }
        if !linked.isEmpty {
            return linked
        }
        return templates.filter { $0.splitId == split.id }
    }

    var body: some View {
        AppScreen(showsNativeNavigationBar: true) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                programNameSection
                routinesSection
            }
        }
        .onChange(of: split.name) { _, _ in
            try? modelContext.save()
        }
        .onAppear {
            syncTemplateOrderIfNeeded()
        }
        .navigationTitle("Edit Program")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Program", systemImage: AppIcon.trash.systemName)
                    }
                } label: {
                    AppIcon.more.image()
                }
                .accessibilityLabel("More")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .appToolbarTextStyle()
            }
        }
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(for: DayTemplate.self) { template in
            TemplateDetailView(template: template)
        }
        .sheet(isPresented: $showAddDay) {
            AddTemplateView(split: split)
                .appBottomSheetChrome()
        }
        .confirmationDialog(
            "Delete Program",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Program", role: .destructive) {
                deleteProgram()
            }
        } message: {
            Text("This will permanently delete this program and all its routine days. This cannot be undone.")
        }
    }

    // MARK: - Sections

    private var programNameSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader("Program Name")

            TextField("Program name", text: $split.name)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textPrimary)
                .textInputAutocapitalization(.words)
                .appInputFieldStyle()
        }
    }

    private var routinesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader("Routines") {
                reorderToggle
            }
            routinesList
        }
    }

    @ViewBuilder
    private var reorderToggle: some View {
        if orderedTemplates.count > 1 {
            Button(isReordering ? "Done" : "Reorder") {
                isReordering.toggle()
            }
            .font(AppFont.caption.font)
            .foregroundStyle(AppColor.accent)
            .accessibilityLabel(isReordering ? "Finish reordering" : "Reorder routines")
        }
    }

    @ViewBuilder
    private var routinesList: some View {
        if isReordering {
            AppCardList(orderedTemplates) { template in
                let index = orderedTemplates.firstIndex(where: { $0.id == template.id }) ?? 0
                reorderRow(template, index: index)
            }
        } else {
            AppCardList(orderedTemplates, row: { template in
                NavigationLink(value: template) {
                    PreviewListRow(
                        title: template.displayName,
                        subtitle: subtitle(for: template)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }, trailing: {
                AppCardListAddRow("Add Day") {
                    showAddDay = true
                }
            })
        }
    }

    // MARK: - Rows

    private func reorderRow(_ template: DayTemplate, index: Int) -> some View {
        HStack(spacing: AppSpacing.sm) {
            PreviewListRow(
                title: template.displayName,
                subtitle: subtitle(for: template)
            )

            VStack(spacing: 0) {
                Button {
                    moveTemplate(at: index, direction: .up)
                } label: {
                    AppIcon.moveUp.image(size: 12, weight: .semibold)
                        .foregroundStyle(index > 0 ? AppColor.textSecondary : AppColor.controlBackground)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(index == 0)
                .accessibilityLabel("Move up")

                Button {
                    moveTemplate(at: index, direction: .down)
                } label: {
                    AppIcon.moveDown.image(size: 12, weight: .semibold)
                        .foregroundStyle(index < orderedTemplates.count - 1 ? AppColor.textSecondary : AppColor.controlBackground)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(index >= orderedTemplates.count - 1)
                .accessibilityLabel("Move down")
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func subtitle(for template: DayTemplate) -> String {
        let count = template.orderedExerciseIds.count
        return count == 0 ? "Add exercises" : "\(count) exercise\(count == 1 ? "" : "s")"
    }

    private enum MoveDirection { case up, down }

    private func moveTemplate(at index: Int, direction: MoveDirection) {
        var ids = split.orderedTemplateIds
        let targetIndex = direction == .up ? index - 1 : index + 1
        guard targetIndex >= 0, targetIndex < ids.count else { return }
        ids.swapAt(index, targetIndex)
        split.orderedTemplateIds = ids
        try? modelContext.save()
    }

    private func syncTemplateOrderIfNeeded() {
        if split.orderedTemplateIds.isEmpty {
            split.orderedTemplateIds = templates
                .filter { $0.splitId == split.id }
                .map(\.id)
            try? modelContext.save()
        }
    }

    private func deleteProgram() {
        let splitId = split.id
        let templatesToDelete = templates.filter { $0.splitId == splitId }
        for t in templatesToDelete {
            modelContext.delete(t)
        }
        modelContext.delete(split)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    TemplatesView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
