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
                ProgramDetailView(split: split)
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

            // MARK: Recent Sessions
            NavigationLink {
                RecentSessionsView(showsCloseButton: false)
            } label: {
                AppGhostButtonLabel(title: "Recent Sessions")
            }
            .buttonStyle(ScaleButtonStyle())

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
            VStack(alignment: .center, spacing: AppSpacing.lg) {
                HStack(alignment: .center, spacing: AppSpacing.sm) {
                    Text(displayName)
                        .font(AppFont.largeTitle.font)
                        .tracking(AppFont.largeTitle.tracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Active")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, AppSpacing.sm)
                        .frame(height: 20)
                        .background(AppColor.controlBackground)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)

                if !days.isEmpty {
                    PreviewListContainer(rowSpacing: AppSpacing.lg) {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, template in
                            NavigationLink(value: template) {
                                PreviewListRow(
                                    title: template.displayName,
                                    subtitle: programRoutineSubtitle(dayIndex: index, template: template),
                                    style: .programRoutine
                                )
                            }
                            .buttonStyle(.plain)
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
                .buttonStyle(.plain)
            }
        }
    }

    private func programRoutineSubtitle(dayIndex: Int, template: DayTemplate) -> String {
        "Day \(dayIndex + 1) · \(routineSummary(for: template))"
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
                // MARK: Program Name
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

                // MARK: Routines
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
                        VStack(spacing: 0) {
                            ForEach(Array(orderedTemplates.enumerated()), id: \.element.id) { index, template in
                                if index > 0 {
                                    AppDivider()
                                        .padding(.horizontal, AppSpacing.md)
                                }

                                editableRoutineRow(template, index: index)
                            }
                        }
                        .background(AppColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    }

                    Button {
                        showAddDay = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            AppIcon.addCircle.image()
                            Text("Add Day")
                                .font(AppFont.body.font)
                        }
                        .foregroundStyle(AppColor.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                // MARK: Delete
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Program")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.md)
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
                Button("Done") { dismiss() }
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

    @ViewBuilder
    private func editableRoutineRow(_ template: DayTemplate, index: Int) -> some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                TextField("Routine name", text: binding(for: template))
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .textInputAutocapitalization(.words)

                Text("\(template.orderedExerciseIds.count) exercise\(template.orderedExerciseIds.count == 1 ? "" : "s")")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 0)

            // Reorder buttons
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

                Button {
                    moveTemplate(at: index, direction: .down)
                } label: {
                    AppIcon.moveDown.image(size: 12, weight: .semibold)
                        .foregroundStyle(index < orderedTemplates.count - 1 ? AppColor.textSecondary : AppColor.disabledSurface)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(index >= orderedTemplates.count - 1)
            }
            .buttonStyle(.plain)

            // Navigate to day exercises
            NavigationLink(value: template) {
                AppIcon.forward.image(size: 14, weight: .semibold)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.smd)
        .frame(minHeight: 44)
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
