//
//  TodayView.swift
//  Unit
//
//  Today: program-first dashboard with one clear workout action.
//

import SwiftUI
import SwiftData

enum TodayDashboardState {
    case noProgram
    case setupIncomplete(SetupIncompleteContext)
    case readyToday(ReadyTodayContext)
    case restDay(RestDayContext)
}

struct ExerciseTarget {
    let exerciseName: String
    let displayTarget: String
    let lastPerformanceLabel: String?
}

struct ReadyTodayContext {
    let weekNumber: Int
    let weekCount: Int
    let programName: String
    let templateName: String
    let progressSteps: [WeeklyProgressStepper.Step]
    let previewTargets: [ExerciseTarget]
    let lastSessionDate: Date?
}

struct SetupIncompleteContext {
    let eyebrow: String
    let title: String
    let message: String
}

struct RestDayContext {
    let weekNumber: Int
    let weekCount: Int
    let progressSteps: [WeeklyProgressStepper.Step]
    let nextTemplateName: String
    let nextTimingLabel: String
    let firstTarget: ExerciseTarget?
}

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTabSelection) private var appTabSelection
    @AppStorage("pendingFeelingSessionId") private var pendingFeelingSessionId = ""

    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query private var cycles: [Cycle]
    @Query private var rules: [ProgressionRule]

    @State private var viewModel = TodayDashboardViewModel()
    @State private var feelingPromptPayload: FeelingPromptPayload?
    @State private var workoutDetailContext: ReadyTodayContext?
    @State private var showsHistory = false

    private var activeSession: WorkoutSession? {
        sessions.first(where: { !$0.isCompleted })
    }

    private var activeCycle: Cycle? {
        cycles.first(where: { $0.isActive && !$0.isCompleted })
            ?? cycles.first(where: { !$0.isCompleted })
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
            activeCycle: activeCycle,
            rules: rules,
            sessions: sessions,
            templates: templates,
            splits: splits,
            exercises: exercises
        )

        return AppScreen(
            title: nil,
            primaryButton: nil,
            customHeader: ProductTopBar(
                title: "Today",
                trailingActions: [
                    .text("History") {
                        showsHistory = true
                    }
                ]
            ).eraseToAnyView(),
            navigationBarTitleDisplayMode: .inline
        ) {
            stateCard(for: state)
        }
        .toolbar(.hidden, for: .navigationBar)
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

        case .restDay(let context):
            RestDayCard(context: context)
        }
    }

    private func startWorkout(named name: String) {
        guard let template = templates.first(where: { $0.name == name }) else { return }
        startWorkout(template)
    }

    private func startWorkout(_ template: DayTemplate) {
        let cycle = activeCycle
        let weekNumber = cycle?.currentWeekNumber ?? 0
        let session = WorkoutSession(
            date: Date(),
            templateId: template.id,
            isCompleted: false,
            overallFeeling: 0,
            cycleId: cycle?.id,
            weekNumber: weekNumber
        )

        modelContext.insert(session)
        template.lastPerformedDate = session.date
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
        "\(weekNumber)-\(templateName)"
    }
}

private struct ReadyTodayCard: View {
    let context: ReadyTodayContext
    let onOpenPreview: () -> Void
    let onStart: () -> Void

    var body: some View {
        HeroWorkoutCard(
            progressSteps: context.progressSteps,
            title: context.templateName,
            subtitle: context.programName,
            previewItems: context.previewTargets.map {
                ExercisePreviewStrip.Item(title: $0.exerciseName, detail: $0.displayTarget)
            },
            onPreviewTap: onOpenPreview,
            onPrimaryAction: onStart
        )
    }

}

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
                            WeeklyProgressStepper(steps: context.progressSteps)

                            Text(context.templateName)
                                .font(AppFont.productHeading)
                                .foregroundStyle(AppColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(context.programName)
                                .font(AppFont.productAction)
                                .foregroundStyle(AppColor.textSecondary)
                                .multilineTextAlignment(.center)
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

private struct RestDayCard: View {
    let context: RestDayContext

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                WeeklyProgressStepper(steps: context.progressSteps)

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text("Rest Day")
                        .font(AppFont.productHeading)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Next: \(context.nextTemplateName) \(context.nextTimingLabel)")
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let firstTarget = context.firstTarget {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("First target")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)

                        Text(firstTarget.exerciseName)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)

                        Text(firstTarget.displayTarget)
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.disabledSurface)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.controlBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
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
                Text("Program")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text("Build your first program")
                        .font(AppFont.productHeading)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Set up one simple recurring program so Unit can show the next target before every set.")
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppPrimaryButton("Go to Program", action: onGoToProgram)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

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

@MainActor
@Observable
final class TodayDashboardViewModel {
    func dashboardState(
        activeCycle: Cycle?,
        rules: [ProgressionRule],
        sessions: [WorkoutSession],
        templates: [DayTemplate],
        splits: [Split],
        exercises: [Exercise]
    ) -> TodayDashboardState {
        guard let cycle = activeCycle else { return .noProgram }

        let orderedTemplates = orderedTemplates(for: cycle, templates: templates, splits: splits)
        guard !orderedTemplates.isEmpty else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: "Program",
                    title: "Finish set up",
                    message: "Add at least one training day before starting workouts."
                )
            )
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cycleStart = calendar.startOfDay(for: cycle.startDate)
        let daysSinceStart = calendar.dateComponents([.day], from: cycleStart, to: today).day ?? 0

        if daysSinceStart < 0, let firstTemplate = orderedTemplates.first {
            let firstTargets = targets(
                for: firstTemplate,
                cycle: cycle,
                rules: rules,
                sessions: sessions,
                exercises: exercises
            )

            guard firstTemplate.orderedExerciseIds.count == firstTargets.count else {
                return .setupIncomplete(
                    SetupIncompleteContext(
                        eyebrow: "Program",
                        title: "Finish set up",
                        message: "Add exercises and starting weights so Unit can prepare the first workout."
                    )
                )
            }

            return .restDay(
                RestDayContext(
                    weekNumber: cycle.currentWeekNumber,
                    weekCount: cycle.weekCount,
                    progressSteps: weeklyProgressSteps(for: cycle, sessions: sessions),
                    nextTemplateName: firstTemplate.name,
                    nextTimingLabel: relativeDayLabel(from: today, to: cycleStart),
                    firstTarget: firstTargets.first
                )
            )
        }

        let effectiveOffset = max(daysSinceStart, 0)
        let trainingDaysPerWeek = min(max(orderedTemplates.count, 1), 6)

        if let todayTemplate = plannedTemplate(
            atDayOffset: effectiveOffset,
            templates: orderedTemplates,
            trainingDaysPerWeek: trainingDaysPerWeek
        ) {
            return stateForTodayTemplate(
                todayTemplate,
                cycle: cycle,
                rules: rules,
                sessions: sessions,
                splits: splits,
                exercises: exercises
            )
        }

        guard let nextPlanned = nextPlannedTemplate(
            fromDayOffset: effectiveOffset,
            templates: orderedTemplates,
            trainingDaysPerWeek: trainingDaysPerWeek
        ) else {
            return .noProgram
        }

        let nextDate = calendar.date(
            byAdding: .day,
            value: nextPlanned.dayOffset - effectiveOffset,
            to: today
        ) ?? today

        let nextTargets = targets(
            for: nextPlanned.template,
            cycle: cycle,
            rules: rules,
            sessions: sessions,
            exercises: exercises
        )

        guard nextPlanned.template.orderedExerciseIds.count == nextTargets.count else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: "Program",
                    title: "Finish set up",
                    message: "Add exercises and starting weights so Unit can prepare the next workout."
                )
            )
        }

        return .restDay(
            RestDayContext(
                weekNumber: cycle.currentWeekNumber,
                weekCount: cycle.weekCount,
                progressSteps: weeklyProgressSteps(for: cycle, sessions: sessions),
                nextTemplateName: nextPlanned.template.name,
                nextTimingLabel: relativeDayLabel(from: today, to: nextDate),
                firstTarget: nextTargets.first
            )
        )
    }

    private func stateForTodayTemplate(
        _ template: DayTemplate,
        cycle: Cycle,
        rules: [ProgressionRule],
        sessions: [WorkoutSession],
        splits: [Split],
        exercises: [Exercise]
    ) -> TodayDashboardState {
        if template.orderedExerciseIds.isEmpty {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: weekLabel(for: cycle),
                    title: template.name,
                    message: "Add at least one exercise before starting this workout."
                )
            )
        }

        let trustedTargets = targets(
            for: template,
            cycle: cycle,
            rules: rules,
            sessions: sessions,
            exercises: exercises
        )

        guard trustedTargets.count == template.orderedExerciseIds.count,
              !trustedTargets.isEmpty else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: weekLabel(for: cycle),
                    title: template.name,
                    message: "Add starting weights for each exercise to see today's targets."
                )
            )
        }

        return .readyToday(
            ReadyTodayContext(
                weekNumber: cycle.currentWeekNumber,
                weekCount: cycle.weekCount,
                programName: programName(for: cycle, splits: splits),
                templateName: template.name,
                progressSteps: weeklyProgressSteps(for: cycle, sessions: sessions),
                previewTargets: trustedTargets,
                lastSessionDate: lastCompletedDate(for: template.id, sessions: sessions)
            )
        )
    }

    private func programName(for cycle: Cycle, splits: [Split]) -> String {
        if let splitID = cycle.splitId,
           let split = splits.first(where: { $0.id == splitID }) {
            let trimmedName = split.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty {
                return trimmedName
            }
        }

        let trimmedName = cycle.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Current cycle" : trimmedName
    }

    private func orderedTemplates(
        for cycle: Cycle,
        templates: [DayTemplate],
        splits: [Split]
    ) -> [DayTemplate] {
        let splitTemplates = templates.filter { $0.splitId == cycle.splitId }
        guard let split = splits.first(where: { $0.id == cycle.splitId }) else {
            return splitTemplates.sorted { $0.name < $1.name }
        }

        let templateByID = Dictionary(uniqueKeysWithValues: splitTemplates.map { ($0.id, $0) })
        let ordered = split.orderedTemplateIds.compactMap { templateByID[$0] }
        return ordered.isEmpty ? splitTemplates.sorted { $0.name < $1.name } : ordered
    }

    private func plannedTemplate(
        atDayOffset dayOffset: Int,
        templates: [DayTemplate],
        trainingDaysPerWeek: Int
    ) -> DayTemplate? {
        guard dayOffset >= 0, !templates.isEmpty else { return nil }

        let week = dayOffset / 7
        let dayInWeek = dayOffset % 7
        guard dayInWeek < trainingDaysPerWeek else { return nil }

        let slotIndex = (week * trainingDaysPerWeek) + dayInWeek
        return templates[slotIndex % templates.count]
    }

    private func nextPlannedTemplate(
        fromDayOffset dayOffset: Int,
        templates: [DayTemplate],
        trainingDaysPerWeek: Int
    ) -> (template: DayTemplate, dayOffset: Int)? {
        guard !templates.isEmpty else { return nil }

        for step in 1...21 {
            let candidateOffset = dayOffset + step
            if let template = plannedTemplate(
                atDayOffset: candidateOffset,
                templates: templates,
                trainingDaysPerWeek: trainingDaysPerWeek
            ) {
                return (template, candidateOffset)
            }
        }

        return nil
    }

    private func targets(
        for template: DayTemplate,
        cycle: Cycle,
        rules: [ProgressionRule],
        sessions: [WorkoutSession],
        exercises: [Exercise]
    ) -> [ExerciseTarget] {
        let weekNumber = cycle.currentWeekNumber
        let lastSession = sessions.first { $0.templateId == template.id && $0.isCompleted }

        return template.orderedExerciseIds.compactMap { exerciseID in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }),
                  let rule = rules.first(where: { $0.exerciseId == exerciseID && $0.cycleId == cycle.id }) else {
                return nil
            }

            let snapshot = rule.snapshot(weekCount: cycle.weekCount)
            let outcomes = rule.buildOutcomes(from: sessions)

            guard let weekTarget = ProgressionEngine.computeTargets(rule: snapshot, outcomes: outcomes)
                .first(where: { $0.weekNumber == weekNumber }),
                let displayTarget = WorkoutTargetFormatter.trustedTargetText(
                    weightKg: weekTarget.weightKg,
                    setCount: max(lastSession?.setEntries.filter {
                        $0.exerciseId == exerciseID && $0.isCompleted && !$0.isWarmup
                    }.count ?? 0, 3),
                    reps: weekTarget.reps,
                    isBodyweight: exercise.isBodyweight
                ) else {
                return nil
            }

            let lastSets = lastSession?.setEntries
                .filter { $0.exerciseId == exerciseID && $0.isCompleted && !$0.isWarmup }
                .sorted { $0.setIndex < $1.setIndex } ?? []

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

    private func weeklyProgressSteps(for cycle: Cycle, sessions: [WorkoutSession]) -> [WeeklyProgressStepper.Step] {
        guard cycle.weekCount > 0 else { return [] }

        let completedWeeks = Set(
            sessions
                .filter { $0.isCompleted && $0.cycleId == cycle.id && $0.weekNumber > 0 }
                .map(\.weekNumber)
        )

        return (1...cycle.weekCount).map { week in
            let state: WeeklyProgressStepper.Step.State
            if completedWeeks.contains(week) {
                state = .completed
            } else if week < cycle.currentWeekNumber {
                state = .missed
            } else if week == cycle.currentWeekNumber {
                state = .current
            } else {
                state = .upcoming
            }

            return WeeklyProgressStepper.Step(
                id: week,
                label: "\(week)",
                state: state
            )
        }
    }

    private func relativeDayLabel(from today: Date, to nextDate: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: today, to: nextDate).day ?? 0

        switch days {
        case ..<0:
            return "Yesterday"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "In \(days) days"
        }
    }

    private func weekLabel(for cycle: Cycle) -> String {
        "Week \(cycle.currentWeekNumber) of \(cycle.weekCount)"
    }
}

#Preview {
    TodayView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
