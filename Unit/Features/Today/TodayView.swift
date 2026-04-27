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
    case restDay(RestDayContext)
}

struct RestDayContext {
    let programName: String
}

struct ExerciseTarget: Identifiable {
    let id = UUID()
    let exerciseName: String
    let displayTarget: String
    let lastPerformanceLabel: String?
    /// True when `displayTarget` is empty-state copy (not a reps/sets metric).
    let isEmptyHint: Bool

    init(
        exerciseName: String,
        displayTarget: String,
        lastPerformanceLabel: String?,
        isEmptyHint: Bool = false
    ) {
        self.exerciseName = exerciseName
        self.displayTarget = displayTarget
        self.lastPerformanceLabel = lastPerformanceLabel
        self.isEmptyHint = isEmptyHint
    }
}

struct ReadyTodayContext {
    let templateId: UUID
    let programName: String
    let templateName: String
    /// Shown when the user picked a different routine than the scheduled one for today.
    let scheduleNote: String?
    let lastPerformedLabel: String?
    let previewTargets: [ExerciseTarget]
    let lastSessionDate: Date?
    /// Position of the suggested routine in the program order (1-based).
    let trainingDayOrdinal: Int
    let trainingDayTotal: Int
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @AppStorage(ActiveSplitStore.defaultsKey) private var activeSplitIdString: String = ""

    @State private var viewModel = TodayDashboardViewModel()
    @State private var workoutDetailContext: ReadyTodayContext?
    @State private var showsHistory = false
    @State private var completedSessionDetail: WorkoutSession?
    @State private var didAppearCard = false
    @State private var staleSessionPrompt: WorkoutSession?
    @State private var toastMessage: String?
    @State private var showsRoutinePickSheet = false
    /// Bumps when override storage changes so `dashboardState` recomputes.
    @State private var routinePickRefresh = 0

    private var activeSession: WorkoutSession? {
        sessions.first(where: { !$0.isCompleted })
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
            .navigationDestination(isPresented: Binding(
                get: { completedSessionDetail != nil },
                set: { if !$0 { completedSessionDetail = nil } }
            )) {
                if let session = completedSessionDetail {
                    let templateName = templates.first(where: { $0.id == session.templateId })?.name ?? "Workout"
                    SessionDetailView(session: session, templateName: templateName)
                }
            }
            .sheet(item: $workoutDetailContext) { context in
                TodayWorkoutDetailsSheet(context: context) {
                    workoutDetailContext = nil
                    startWorkout(templateId: context.templateId)
                }
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
            }
            .tint(AppColor.systemTint)
            .onAppear {
                checkStaleSession()
                QuickStartSupport.cleanupOrphanedTemplates(
                    modelContext: modelContext,
                    templates: templates,
                    sessions: sessions
                )
            }
            .onChange(of: activeSession) { oldValue, newValue in
                guard let previous = oldValue, newValue == nil else { return }
                // Only show summary for the session that was just finished — not any older
                // completed workout (cancel deletes the session, so there is no match).
                let previousId = previous.id
                if let match = sessions.first(where: { $0.id == previousId && $0.isCompleted }) {
                    completedSessionDetail = match
                }
            }
            .alert(
                "Workout from yesterday",
                isPresented: Binding(
                    get: { staleSessionPrompt != nil },
                    set: { if !$0 { staleSessionPrompt = nil } }
                ),
                presenting: staleSessionPrompt
            ) { session in
                Button(AppCopy.Session.markComplete) {
                    saveStaleSession(session)
                }
                Button(AppCopy.Session.discard, role: .destructive) {
                    discardStaleSession(session)
                }
            } message: { _ in
                Text("You left a workout in progress. Mark it complete or discard it.")
            }
            .appToast(message: $toastMessage)
        }
    }

    private var dashboardContent: some View {
        let _ = routinePickRefresh
        let state = viewModel.dashboardState(
            sessions: sessions,
            templates: templates,
            splits: splits,
            exercises: exercises
        )

        return AppScreen(
            showsNativeNavigationBar: true,
            usesOuterScroll: false
        ) {
            // Hero: Up Next / Rest Day / Empty state — always the first, most
            // prominent surface on screen (compass: Today → Start in ≤ 2 taps).
            stateCard(for: state)
                .opacity(didAppearCard ? 1 : 0)
                .offset(y: didAppearCard ? 0 : 10)
        }
        .onAppear {
            guard !didAppearCard else { return }
            if reduceMotion {
                didAppearCard = true
            } else {
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    didAppearCard = true
                }
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if routinePickerAllowed(for: state) {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showsRoutinePickSheet = true
                    } label: {
                        Label("Today's routine", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel("Choose today's routine")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(AppCopy.Nav.history) {
                    showsHistory = true
                }
                .appToolbarTextStyle()
            }
        }
        .sheet(isPresented: $showsRoutinePickSheet) {
            routinePickSheet
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .appNavigationBarChrome()
    }

    private func routinePickerAllowed(for state: TodayDashboardState) -> Bool {
        switch state {
        case .readyToday, .restDay:
            guard let split = ActiveSplitStore.resolve(from: splits) else { return false }
            let ordered = viewModel.orderedTemplates(for: split, templates: templates)
            return !ordered.isEmpty
        case .noProgram, .setupIncomplete:
            return false
        }
    }

    private var routinePickSheet: some View {
        Group {
            if let split = ActiveSplitStore.resolve(from: splits) {
                let ordered = viewModel.orderedTemplates(for: split, templates: templates)
                let hasSchedule = ordered.contains { $0.scheduledWeekday > 0 }
                let hasOverride = TodayRoutineOverride.effectiveTemplateId(orderedTemplateIds: ordered.map(\.id)) != nil
                TodayRoutinePickSheet(
                    programName: split.name,
                    orderedTemplates: ordered,
                    hasWeeklySchedule: hasSchedule,
                    todayWeekday: Calendar.current.component(.weekday, from: Date()),
                    hasActiveOverride: hasOverride,
                    onSelect: { id in
                        TodayRoutineOverride.set(templateId: id)
                        routinePickRefresh += 1
                        showsRoutinePickSheet = false
                    },
                    onUseDefault: {
                        TodayRoutineOverride.clear()
                        routinePickRefresh += 1
                        showsRoutinePickSheet = false
                    }
                )
            } else {
                Color.clear
                    .task { showsRoutinePickSheet = false }
            }
        }
    }

    @ViewBuilder
    private func stateCard(for state: TodayDashboardState) -> some View {
        switch state {
        case .noProgram:
            EmptyStateCard(
                eyebrow: "Programs",
                title: "Create your first program",
                message: "Set up one simple recurring program so Unit can show the last session before every set.",
                buttonLabel: "Create program"
            ) {
                appTabSelection(.program)
            }

        case .setupIncomplete(let context):
            EmptyStateCard(
                eyebrow: context.eyebrow,
                title: context.title,
                message: context.message,
                buttonLabel: "Finish set up"
            ) {
                appTabSelection(.program)
            }

        case .readyToday(let context):
            ReadyTodayCard(
                context: context,
                onOpenPreview: {
                    workoutDetailContext = context
                },
                onStart: {
                    startWorkout(templateId: context.templateId)
                }
            )

        case .restDay(let context):
            RestDayCard(context: context)
        }
    }

    private func startWorkout(templateId: UUID) {
        guard let template = templates.first(where: { $0.id == templateId }) else { return }
        startWorkout(template)
    }

    private func startWorkout(_ template: DayTemplate) {
        let session = WorkoutSession(
            date: Date(),
            templateId: template.id,
            isCompleted: false
        )

        modelContext.insert(session)
        template.lastPerformedDate = session.date
        try? modelContext.save()
    }

    private func checkStaleSession() {
        guard let session = activeSession else { return }
        guard Date().timeIntervalSince(session.date) > 86400 else { return }

        // Auto-discard truly empty sessions; surface a toast so the user knows.
        let hasLoggedSets = session.setEntries.contains(where: { $0.isCompleted })
        if !hasLoggedSets {
            modelContext.delete(session)
            try? modelContext.save()
            toastMessage = "Discarded empty session from yesterday"
            return
        }

        // Sessions with logged work require explicit Save / Discard.
        staleSessionPrompt = session
    }

    private func saveStaleSession(_ session: WorkoutSession) {
        session.isCompleted = true
        try? modelContext.save()
        // Land on SessionDetailView via the existing completedSessionDetail path.
        completedSessionDetail = session
    }

    private func discardStaleSession(_ session: WorkoutSession) {
        modelContext.delete(session)
        try? modelContext.save()
    }

}

extension ReadyTodayContext: Identifiable {
    var id: String { templateId.uuidString }
}

// MARK: - Ready Today Card

private struct ReadyTodayCard: View {
    let context: ReadyTodayContext
    let onOpenPreview: () -> Void
    let onStart: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                AppTag(
                    text: "Up next",
                    style: .custom(fg: AppColor.textSecondary, bg: AppColor.controlBackground),
                    layout: .compactCapsule
                )

                VStack(spacing: AppSpacing.xs) {
                    Text(context.templateName)
                        .font(AppFont.productHeading)
                        .tracking(AppFont.productHeadingTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(context.programName)
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)

                    if let note = context.scheduleNote {
                        Text(note)
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.secondaryLabel)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)

                if !context.previewTargets.isEmpty {
                    Button {
                        onOpenPreview()
                    } label: {
                        PreviewListContainer {
                            ForEach(Array(context.previewTargets.enumerated()), id: \.offset) { _, target in
                                PreviewListRow(
                                    title: target.exerciseName,
                                    subtitle: target.displayTarget,
                                    isEmptyHint: target.isEmptyHint
                                )
                            }
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .frame(maxWidth: .infinity)
                }

                AppPrimaryButton(AppCopy.Workout.startWorkout, action: onStart)
            }
        }
    }
}

// MARK: - Rest Day Card

private struct RestDayCard: View {
    let context: RestDayContext

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                AppTag(
                    text: "Rest day",
                    style: .custom(fg: AppColor.textSecondary, bg: AppColor.controlBackground),
                    layout: .compactCapsule
                )

                VStack(spacing: AppSpacing.xs) {
                    Text("Enjoy your rest")
                        .font(AppFont.productHeading)
                        .tracking(AppFont.productHeadingTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(context.programName)
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
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
                        .text(AppCopy.Nav.close) {
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
                                .tracking(AppFont.productHeadingTracking)
                                .foregroundStyle(AppColor.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(context.programName)
                                .font(AppFont.productAction)
                                .foregroundStyle(AppColor.textSecondary)
                                .multilineTextAlignment(.center)

                            if let note = context.scheduleNote {
                                Text(note)
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(AppColor.secondaryLabel)
                                    .multilineTextAlignment(.center)
                            }

                            if let lastLabel = context.lastPerformedLabel {
                                Text(lastLabel)
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        AppDividedList(context.previewTargets) { target in
                            AppListRow(
                                title: target.exerciseName,
                                subtitle: target.lastPerformanceLabel
                            ) {
                                Text(target.displayTarget)
                                    .font(AppFont.productAction)
                                    .foregroundStyle(target.isEmptyHint ? AppColor.secondaryLabel : AppColor.textSecondary)
                                    .monospacedDigit()
                            }
                        }
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                        AppPrimaryButton(AppCopy.Workout.startWorkout, action: onStart)
                    }
                }
            }
        }
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
        guard let split = ActiveSplitStore.resolve(from: splits) else { return .noProgram }

        let orderedTemplates = orderedTemplates(for: split, templates: templates)
        let orderedIds = orderedTemplates.map(\.id)
        let todayOverrideTemplateId = TodayRoutineOverride.effectiveTemplateId(orderedTemplateIds: orderedIds)

        guard !orderedTemplates.isEmpty else {
            return .setupIncomplete(
                SetupIncompleteContext(
                    eyebrow: "Programs",
                    title: "Finish set up",
                    message: "Add at least one routine before starting workouts."
                )
            )
        }

        // Weekday-aware scheduling when templates have scheduledWeekday set
        let hasSchedule = orderedTemplates.contains { $0.scheduledWeekday > 0 }
        if hasSchedule {
            return scheduledDashboardState(
                split: split,
                orderedTemplates: orderedTemplates,
                templates: templates,
                sessions: sessions,
                exercises: exercises,
                todayOverrideTemplateId: todayOverrideTemplateId
            )
        }

        // Legacy rotation: pick template with oldest lastPerformedDate.
        // If any template in the rotation was already completed today, treat
        // today as a rest day (matches scheduledDashboardState behaviour).
        let calendar = Calendar.current

        if let overrideId = todayOverrideTemplateId,
           let picked = orderedTemplates.first(where: { $0.id == overrideId }) {
            let completedPicked = sessions.contains { session in
                session.templateId == picked.id &&
                session.isCompleted &&
                calendar.isDateInToday(session.date)
            }
            if completedPicked {
                return .restDay(RestDayContext(programName: split.name))
            }
            return stateForTemplate(
                picked,
                split: split,
                templates: templates,
                sessions: sessions,
                exercises: exercises,
                scheduleNote: "Different routine for today"
            )
        }

        let completedTodayInRotation = orderedTemplates.contains { template in
            sessions.contains { session in
                session.templateId == template.id &&
                session.isCompleted &&
                calendar.isDateInToday(session.date)
            }
        }
        if completedTodayInRotation {
            return .restDay(RestDayContext(programName: split.name))
        }

        guard let nextTemplate = orderedTemplates
            .sorted(by: { ($0.lastPerformedDate ?? .distantPast) < ($1.lastPerformedDate ?? .distantPast) })
            .first else { return .noProgram }

        return stateForTemplate(
            nextTemplate,
            split: split,
            templates: templates,
            sessions: sessions,
            exercises: exercises,
            scheduleNote: nil
        )
    }

    private func scheduledDashboardState(
        split: Split,
        orderedTemplates: [DayTemplate],
        templates: [DayTemplate],
        sessions: [WorkoutSession],
        exercises: [Exercise],
        todayOverrideTemplateId: UUID?
    ) -> TodayDashboardState {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())
        let scheduledTemplate = orderedTemplates.first { $0.scheduledWeekday == todayWeekday }

        let activeTemplate: DayTemplate? = {
            if let oid = todayOverrideTemplateId,
               let picked = orderedTemplates.first(where: { $0.id == oid }) {
                return picked
            }
            return scheduledTemplate
        }()

        guard let template = activeTemplate else {
            return .restDay(RestDayContext(programName: split.name))
        }

        let completedToday = sessions.contains { session in
            session.templateId == template.id &&
            session.isCompleted &&
            calendar.isDateInToday(session.date)
        }
        if completedToday {
            return .restDay(RestDayContext(programName: split.name))
        }

        let note = scheduleOverrideNote(
            scheduledTemplate: scheduledTemplate,
            activeTemplate: template,
            todayOverrideTemplateId: todayOverrideTemplateId
        )

        return stateForTemplate(
            template,
            split: split,
            templates: templates,
            sessions: sessions,
            exercises: exercises,
            scheduleNote: note
        )
    }

    private func scheduleOverrideNote(
        scheduledTemplate: DayTemplate?,
        activeTemplate: DayTemplate,
        todayOverrideTemplateId: UUID?
    ) -> String? {
        guard todayOverrideTemplateId != nil else { return nil }
        if let scheduled = scheduledTemplate, scheduled.id != activeTemplate.id {
            return "Usually \(scheduled.displayName) today"
        }
        if scheduledTemplate == nil {
            return "Extra session (not on your weekly plan)"
        }
        return nil
    }

    private func stateForTemplate(
        _ template: DayTemplate,
        split: Split,
        templates: [DayTemplate],
        sessions: [WorkoutSession],
        exercises: [Exercise],
        scheduleNote: String?
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

        let orderedRoutines = orderedTemplates(for: split, templates: templates)
        let templateIndex = orderedRoutines.firstIndex { $0.id == template.id }
        let dayOrdinal = templateIndex.map { $0 + 1 } ?? 1
        let dayTotal = max(orderedRoutines.count, 1)

        return .readyToday(
            ReadyTodayContext(
                templateId: template.id,
                programName: split.name,
                templateName: template.name,
                scheduleNote: scheduleNote,
                lastPerformedLabel: lastLabel,
                previewTargets: previewTargets,
                lastSessionDate: lastDate,
                trainingDayOrdinal: dayOrdinal,
                trainingDayTotal: dayTotal
            )
        )
    }

    func orderedTemplates(
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
        let hasAnyCompleted = sessions.contains(where: \.isCompleted)
        // Ghost values: last completed working sets per exercise from any session (newest first).
        // Matches TemplateDetailView / ActiveWorkout prefill — not limited to this template.
        return template.orderedExerciseIds.compactMap { exerciseID in
            guard let exercise = exercises.first(where: { $0.id == exerciseID }) else {
                return nil
            }

            // Cold-start: explicit copy instead of a dash — distinguish app-wide vs first time for this lift.
            guard let ghostSession = sessions.first(where: { session in
                session.isCompleted &&
                session.setEntries.contains(where: {
                    $0.exerciseId == exerciseID && $0.isCompleted && !$0.isWarmup
                })
            }) else {
                return ExerciseTarget(
                    exerciseName: exercise.displayName,
                    displayTarget: hasAnyCompleted
                        ? AppCopy.EmptyState.noPriorSets
                        : AppCopy.EmptyState.noHistoryYet,
                    lastPerformanceLabel: nil,
                    isEmptyHint: true
                )
            }

            let lastSets = ghostSession.setEntries
                .filter { $0.exerciseId == exerciseID && $0.isCompleted && !$0.isWarmup }
                .sorted { $0.setIndex < $1.setIndex }

            guard let representative = lastSets.last, representative.reps > 0 else {
                return ExerciseTarget(
                    exerciseName: exercise.displayName,
                    displayTarget: hasAnyCompleted
                        ? AppCopy.EmptyState.noPriorSets
                        : AppCopy.EmptyState.noHistoryYet,
                    lastPerformanceLabel: nil,
                    isEmptyHint: true
                )
            }

            if !exercise.isBodyweight, representative.weight <= 0 {
                return ExerciseTarget(
                    exerciseName: exercise.displayName,
                    displayTarget: hasAnyCompleted
                        ? AppCopy.EmptyState.noPriorSets
                        : AppCopy.EmptyState.noHistoryYet,
                    lastPerformanceLabel: nil,
                    isEmptyHint: true
                )
            }

            let displayTarget = "\(max(lastSets.count, 1)) × \(representative.reps)"

            let weightLabel: String
            if exercise.isBodyweight {
                weightLabel = "BW"
            } else {
                weightLabel = WorkoutTargetFormatter.weightDisplay(representative.weight)
            }
            let lastPerformanceLabel = "Last \(weightLabel)"

            return ExerciseTarget(
                exerciseName: exercise.displayName,
                displayTarget: displayTarget,
                lastPerformanceLabel: lastPerformanceLabel,
                isEmptyHint: false
            )
        }
    }

    private func lastCompletedDate(for templateID: UUID, sessions: [WorkoutSession]) -> Date? {
        sessions.first { $0.isCompleted && $0.templateId == templateID }?.date
    }
}

// MARK: - Today's routine picker

private struct TodayRoutinePickSheet: View {
    let programName: String
    let orderedTemplates: [DayTemplate]
    let hasWeeklySchedule: Bool
    let todayWeekday: Int
    let hasActiveOverride: Bool
    let onSelect: (UUID) -> Void
    let onUseDefault: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(orderedTemplates, id: \.id) { template in
                        Button {
                            onSelect(template.id)
                        } label: {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                    Text(template.displayName)
                                        .font(AppFont.body.font)
                                        .foregroundStyle(AppColor.textPrimary)
                                    if template.scheduledWeekday > 0, let w = weekdayShort(template.scheduledWeekday) {
                                        Text(w)
                                            .font(AppFont.caption.font)
                                            .foregroundStyle(AppColor.textSecondary)
                                    }
                                }
                                Spacer(minLength: AppSpacing.sm)
                                if hasWeeklySchedule, template.scheduledWeekday == todayWeekday {
                                    Text("Plan")
                                        .font(AppFont.caption.font.weight(.medium))
                                        .foregroundStyle(AppColor.secondaryLabel)
                                }
                            }
                            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                        }
                    }
                } header: {
                    Text(programName)
                }
            }
            .navigationTitle("Today's routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() } label: {
                        Label(AppCopy.Nav.close, systemImage: AppIcon.close.systemName)
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel(AppCopy.Nav.close)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if hasActiveOverride {
                    AppPrimaryButton(hasWeeklySchedule ? "Use scheduled day" : "Use suggested routine") {
                        onUseDefault()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.sm)
                    .background(AppColor.background)
                }
            }
            .appNavigationBarChrome()
        }
        .tint(AppColor.systemTint)
    }

    private func weekdayShort(_ weekday: Int) -> String? {
        guard weekday >= 1, weekday <= 7 else { return nil }
        return Calendar.current.shortWeekdaySymbols[weekday - 1]
    }
}

#Preview {
    TodayView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
