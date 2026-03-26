//
//  TodayView.swift
//  Unit
//
//  Today: template-first dashboard — next workout, freestyle, or resume.
//

import SwiftUI
import SwiftData

// MARK: - Dashboard state

enum TodayDashboardState {
    case noProgram
    case setupIncomplete(SetupIncompleteContext)
    case readyToday(ReadyTodayContext)
}

struct ExerciseTarget {
    let exerciseName: String
    let displayTarget: String
    let lastPerformanceLabel: String?
}

struct ReadyTodayContext {
    let programName: String
    let templateName: String
    let lastPerformedLabel: String?
    let previewTargets: [ExerciseTarget]
    let lastSessionDate: Date?
}

struct SetupIncompleteContext {
    let eyebrow: String
    let title: String
    let message: String
}

// MARK: - TodayView

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTabSelection) private var appTabSelection
    @AppStorage("pendingFeelingSessionId") private var pendingFeelingSessionId = ""

    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @State private var viewModel = TodayDashboardViewModel()
    @State private var feelingPromptPayload: FeelingPromptPayload?
    @State private var workoutDetailContext: ReadyTodayContext?
    @State private var showsHistory = false

    private var activeSession: WorkoutSession? {
        sessions.first(where: { !$0.isCompleted })
    }

    private var activeSplit: Split? {
        splits.first
    }

    var body: some View {
        NavigationStack {
            Group {
                if let session = activeSession {
                    ActiveWorkoutView(session: session)
                } else {
                    dashboardContent
                }
            }
            .navigationDestination(isPresented: $showsHistory) {
                RecentSessionsView(showsCloseButton: true, initialMode: .list)
            }
            .sheet(item: $feelingPromptPayload) { payload in
                PostWorkoutFeelingPrompt(session: payload.session) {
                    pendingFeelingSessionId = ""
                }
                .presentationDetents([.height(220)])
                .appBottomSheetChrome()
            }
            .sheet(item: $workoutDetailContext) { context in
                TodayWorkoutDetailsSheet(context: context) {
                    workoutDetailContext = nil
                    startWorkout(named: context.templateName)
                }
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
            }
            .tint(AppColor.accent)
            .onAppear {
                abandonStaleSession()
                presentPendingFeelingPromptIfNeeded()
            }
            .onChange(of: sessions.count) { _, _ in
                presentPendingFeelingPromptIfNeeded()
            }
        }
    }

    private var dashboardContent: some View {
        let state = viewModel.dashboardState(
            sessions: sessions,
            templates: templates,
            splits: splits,
            exercises: exercises
        )

        return AppScreen(
            showsNativeNavigationBar: true
        ) {
            VStack(spacing: AppSpacing.md) {
                stateCard(for: state)

                AppSecondaryButton("Start Empty Workout") {
                    startEmptyWorkout()
                }
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsHistory = true
                } label: {
                    Image(systemName: AppIcon.calendarPlain.systemName)
                }
            }
        }
        .appNavigationBarChrome()
    }

    @ViewBuilder
    private func stateCard(for state: TodayDashboardState) -> some View {
        switch state {
        case .noProgram:
            NoProgramCard {
                appTabSelection(.program)
            }

        case .setupIncomplete(let context):
            SetupIncompleteCard(context: context) {
                appTabSelection(.program)
            }

        case .readyToday(let context):
            ReadyTodayCard(
                context: context,
                onOpenPreview: {
                    workoutDetailContext = context
                },
                onStart: {
                    startWorkout(named: context.templateName)
                }
            )
        }
    }

    private func startWorkout(named name: String) {
        guard let template = templates.first(where: { $0.name == name }) else { return }
        startWorkout(template)
    }

    private func startWorkout(_ template: DayTemplate) {
        let session = WorkoutSession(
            date: Date(),
            templateId: template.id,
            isCompleted: false,
            overallFeeling: 0,
            cycleId: nil,
            weekNumber: 0
        )

        modelContext.insert(session)
        template.lastPerformedDate = session.date
        try? modelContext.save()
    }

    private func startEmptyWorkout() {
        let emptyTemplate = DayTemplate(
            name: "Freestyle",
            splitId: activeSplit?.id,
            orderedExerciseIds: []
        )
        modelContext.insert(emptyTemplate)

        let session = WorkoutSession(
            date: Date(),
            templateId: emptyTemplate.id,
            isCompleted: false,
            overallFeeling: 0,
            cycleId: nil,
            weekNumber: 0
        )
        modelContext.insert(session)
        try? modelContext.save()
    }

    private func abandonStaleSession() {
        guard let session = activeSession else { return }
        if Date().timeIntervalSince(session.date) > 86400 {
            modelContext.delete(session)
            try? modelContext.save()
        }
    }

    private func presentPendingFeelingPromptIfNeeded() {
        guard activeSession == nil else { return }
        guard !pendingFeelingSessionId.isEmpty else { return }
        guard let sessionID = UUID(uuidString: pendingFeelingSessionId) else {
            pendingFeelingSessionId = ""
            return
        }
        guard let session = sessions.first(where: { $0.id == sessionID && $0.isCompleted }) else { return }
        feelingPromptPayload = FeelingPromptPayload(session: session)
    }

}

extension ReadyTodayContext: Identifiable {
    var id: String {
        templateName
    }
}

// MARK: - Ready Today Card

private struct ReadyTodayCard: View {
    let context: ReadyTodayContext
    let onOpenPreview: () -> Void
    let onStart: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.xs) {
                        Text(context.templateName)
                            .font(AppFont.productHeading)
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(context.programName)
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)

                        if let lastLabel = context.lastPerformedLabel {
                            Text(lastLabel)
                                .font(AppFont.caption.font)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.lg)

                    if !context.previewTargets.isEmpty {
                        ExercisePreviewStrip(
                            items: context.previewTargets.map {
                                ExercisePreviewStrip.Item(title: $0.exerciseName, detail: $0.displayTarget)
                            }
                        ) { _ in
                            onOpenPreview()
                        }
                    }
                }

                AppPrimaryButton("Start", action: onStart)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Workout Details Sheet

private struct TodayWorkoutDetailsSheet: View {
    let context: ReadyTodayContext
    let onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AppScreen(
                title: nil,
                customHeader: ProductTopBar(
                    title: "Workout",
                    trailingActions: [
                        .icon(.close) {
                            dismiss()
                        }
                    ]
                ).eraseToAnyView()
            ) {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        VStack(alignment: .center, spacing: AppSpacing.sm) {
                            Text(context.templateName)
                                .font(AppFont.productHeading)
                                .foregroundStyle(AppColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(context.programName)
                                .font(AppFont.productAction)
                                .foregroundStyle(AppColor.textSecondary)
                                .multilineTextAlignment(.center)

                            if let lastLabel = context.lastPerformedLabel {
                                Text(lastLabel)
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(context.previewTargets.enumerated()), id: \.offset) { index, target in
                                AppListRow(
                                    title: target.exerciseName,
                                    subtitle: target.lastPerformanceLabel
                                ) {
                                    Text(target.displayTarget)
                                        .font(AppFont.productAction)
                                        .foregroundStyle(AppColor.textSecondary)
                                        .monospacedDigit()
                                }

                                if index < context.previewTargets.count - 1 {
                                    AppDivider()
                                }
                            }
                        }
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                        AppPrimaryButton("Start", action: onStart)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Cards

private struct SetupIncompleteCard: View {
    let context: SetupIncompleteContext
    let onOpenProgram: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                Text(context.eyebrow)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text(context.title)
                        .font(AppFont.productHeading)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(context.message)
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppPrimaryButton("Finish set up", action: onOpenProgram)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct NoProgramCard: View {
    let onGoToProgram: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                Text("Templates")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text("Build your first program")
                        .font(AppFont.productHeading)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Set up one simple recurring program so Unit can show the last session before every set.")
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppPrimaryButton("Go to Templates", action: onGoToProgram)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Post-Workout Feeling

private struct FeelingPromptPayload: Identifiable {
    let id = UUID()
    let session: WorkoutSession
}

private struct PostWorkoutFeelingPrompt: View {
    @Bindable var session: WorkoutSession
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let onDismiss: () -> Void

    @State private var savedFeeling: Int?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if let saved = savedFeeling {
                    VStack(spacing: AppSpacing.sm) {
                        AppIcon.checkmarkFilled.image(size: 28, weight: .semibold)
                            .foregroundStyle(AppColor.success)
                        Text("Saved — \(saved)/5")
                            .font(AppFont.title.font)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.lg)
                } else {
                    Text("How did it feel?")
                        .font(AppFont.title.font)
                        .foregroundStyle(AppColor.textPrimary)

                    HStack(spacing: AppSpacing.sm) {
                        ForEach(1...5, id: \.self) { value in
                            feelingButton(value)
                        }
                    }

                    AppSecondaryButton("Skip") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.sheetBackground.ignoresSafeArea())
        .onDisappear {
            onDismiss()
        }
    }

    private func feelingButton(_ value: Int) -> some View {
        Button {
            session.overallFeeling = value
            try? modelContext.save()
            withAnimation(.easeInOut(duration: 0.2)) {
                savedFeeling = value
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onDismiss()
                dismiss()
            }
        } label: {
            Text("\(value)")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(session.overallFeeling == value ? AppColor.accentForeground : AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(session.overallFeeling == value ? AppColor.accent : AppColor.controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Model

@MainActor
@Observable
final class TodayDashboardViewModel {
    func dashboardState(
        sessions: [WorkoutSession],
        templates: [DayTemplate],
        splits: [Split],
        exercises: [Exercise]
    ) -> TodayDashboardState {
        guard let split = splits.first else { return .noProgram }

        let orderedTemplates = orderedTemplates(for: split, templates: templates)
        guard !orderedTemplates.isEmpty else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: "Templates",
                    title: "Finish set up",
                    message: "Add at least one routine before starting workouts."
                )
            )
        }

        // Pick the next template: the one with the oldest (or nil) lastPerformedDate
        let nextTemplate = orderedTemplates
            .sorted { ($0.lastPerformedDate ?? .distantPast) < ($1.lastPerformedDate ?? .distantPast) }
            .first!

        return stateForTemplate(
            nextTemplate,
            split: split,
            sessions: sessions,
            exercises: exercises
        )
    }

    private func stateForTemplate(
        _ template: DayTemplate,
        split: Split,
        sessions: [WorkoutSession],
        exercises: [Exercise]
    ) -> TodayDashboardState {
        if template.orderedExerciseIds.isEmpty {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: split.name,
                    title: template.displayName,
                    message: "Add at least one exercise before starting this workout."
                )
            )
        }

        let previewTargets = exercisePreviews(
            for: template,
            sessions: sessions,
            exercises: exercises
        )

        guard !previewTargets.isEmpty else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: split.name,
                    title: template.displayName,
                    message: "Add exercises to see today's targets."
                )
            )
        }

        let lastDate = lastCompletedDate(for: template.id, sessions: sessions)
        let lastLabel: String? = lastDate.map { date in
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: date), to: Calendar.current.startOfDay(for: Date())).day ?? 0
            switch days {
            case 0: return "Last performed today"
            case 1: return "Last performed yesterday"
            default: return "Last performed \(days) days ago"
            }
        }

        return .readyToday(
            ReadyTodayContext(
                programName: split.name,
                templateName: template.name,
                lastPerformedLabel: lastLabel,
                previewTargets: previewTargets,
                lastSessionDate: lastDate
            )
        )
    }

    private func orderedTemplates(
        for split: Split,
        templates: [DayTemplate]
    ) -> [DayTemplate] {
        let splitTemplates = templates.filter { $0.splitId == split.id }
        let templateByID = Dictionary(uniqueKeysWithValues: splitTemplates.map { ($0.id, $0) })
        let ordered = split.orderedTemplateIds.compactMap { templateByID[$0] }
        return ordered.isEmpty ? splitTemplates.sorted { $0.name < $1.name } : ordered
    }

    private func exercisePreviews(
        for template: DayTemplate,
        sessions: [WorkoutSession],
        exercises: [Exercise]
    ) -> [ExerciseTarget] {
        let lastSession = sessions.first { $0.templateId == template.id && $0.isCompleted }

        return template.orderedExerciseIds.compactMap { exerciseID in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }) else {
                return nil
            }

            let lastSets = lastSession?.setEntries
                .filter { $0.exerciseId == exerciseID && $0.isCompleted && !$0.isWarmup }
                .sorted { $0.setIndex < $1.setIndex } ?? []

            let displayTarget: String
            if let representative = lastSets.last {
                displayTarget = WorkoutTargetFormatter.actualText(
                    weightKg: representative.weight,
                    setCount: max(lastSets.count, 1),
                    reps: representative.reps,
                    isBodyweight: exercise.isBodyweight
                )
            } else {
                displayTarget = "No history yet"
            }

            let lastPerformanceLabel = lastSets.last.map {
                WorkoutTargetFormatter.lastText(
                    weightKg: $0.weight,
                    setCount: lastSets.count,
                    reps: $0.reps,
                    isBodyweight: exercise.isBodyweight
                )
            }

            return ExerciseTarget(
                exerciseName: exercise.displayName,
                displayTarget: displayTarget,
                lastPerformanceLabel: lastPerformanceLabel
            )
        }
    }

    private func lastCompletedDate(for templateID: UUID, sessions: [WorkoutSession]) -> Date? {
        sessions.first { $0.isCompleted && $0.templateId == templateID }?.date
    }
}

#Preview {
    TodayView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
