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
            .tint(AppColor.systemTint)
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
                Text("All Programs")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.md)
                    .padding(.leading, AppSpacing.md)

                AppDividedList(stacked: inactiveSplits) { split in
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
            VStack(alignment: .center, spacing: AppSpacing.md) {
                HStack {
                    Spacer(minLength: 0)
                    HStack(alignment: .center, spacing: AppSpacing.sm) {
                        Text(displayName)
                            .font(AppFont.largeTitle.font)
                            .tracking(AppFont.largeTitle.tracking)
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        AppTag(text: "Active", style: .muted, layout: .compactCapsule)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(displayName), active program")
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)

                if !days.isEmpty {
                    PreviewListContainer {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, template in
                            NavigationLink(value: template) {
                                PreviewListRow(
                                    title: template.displayName,
                                    subtitle: programRoutineSubtitle(dayIndex: index, template: template)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }

                NavigationLink(value: split) {
                    Text("Program Details")
                        .font(AppFont.label.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private func programRoutineSubtitle(dayIndex: Int, template: DayTemplate) -> String {
        routineSummary(for: template)
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
                addDayButton
                deleteFooter
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
            ToolbarItem(placement: .confirmationAction) {
                if isReordering {
                    Button("Done") { isReordering = false }
                        .appToolbarTextStyle()
                } else {
                    Button("Done") { dismiss() }
                        .appToolbarTextStyle()
                }
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
    }

    private var routinesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("Routines")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.leading, AppSpacing.xs)

                Spacer()

                if orderedTemplates.count > 1 {
                    Button(isReordering ? "Done" : "Reorder") {
                        isReordering.toggle()
                    }
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.systemTint)
                    .padding(.trailing, AppSpacing.xs)
                    .accessibilityLabel(isReordering ? "Finish reordering" : "Reorder routines")
                }
            }

            if orderedTemplates.isEmpty {
                AppCard {
                    Text("No routines in this program yet.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                AppDividedList(stacked: orderedTemplates) { template in
                    let index = orderedTemplates.firstIndex(where: { $0.id == template.id }) ?? 0
                    routineRow(template, index: index)
                }
            }
        }
    }

    private var addDayButton: some View {
        AppGhostButton("Add Day") {
            showAddDay = true
        }
    }

    private var deleteFooter: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Text("Delete Program")
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.top, AppSpacing.xxl)
    }

    // MARK: - Rows

    @ViewBuilder
    private func routineRow(_ template: DayTemplate, index: Int) -> some View {
        if isReordering {
            reorderRow(template, index: index)
        } else {
            NavigationLink(value: template) {
                rowContent(template)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    private func rowContent(_ template: DayTemplate) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(template.displayName)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)

            Text(subtitle(for: template))
                .font(AppFont.listSecondary.font)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func reorderRow(_ template: DayTemplate, index: Int) -> some View {
        HStack(spacing: AppSpacing.sm) {
            rowContent(template)

            VStack(spacing: 0) {
                Button {
                    moveTemplate(at: index, direction: .up)
                } label: {
                    AppIcon.moveUp.image(size: 12, weight: .semibold)
                        .foregroundStyle(index > 0 ? AppColor.textSecondary : AppColor.disabledSurface)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(index == 0)
                .accessibilityLabel("Move up")

                Button {
                    moveTemplate(at: index, direction: .down)
                } label: {
                    AppIcon.moveDown.image(size: 12, weight: .semibold)
                        .foregroundStyle(index < orderedTemplates.count - 1 ? AppColor.textSecondary : AppColor.disabledSurface)
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
