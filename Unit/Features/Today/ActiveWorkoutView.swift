//
//  ActiveWorkoutView.swift
//  Unit
//
//  Active workout: command-panel logging for the current exercise and rest state.
//

import ActivityKit
import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Bindable var session: WorkoutSession

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]

    @State private var viewModel = ActiveWorkoutViewModel()
    @State private var restTimer = RestTimerManager()
    @State private var restDurationSeconds = 30
    @State private var showLineup = false
    @State private var showLogs = false
    @State private var adjustResultPayload: AdjustResultPayload?
    @State private var selectedExerciseIndex = 0
    @State private var showsReadyState = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsCancelConfirmation = false
    @State private var showsSkipExerciseConfirmation = false
    @State private var showsFinishConfirmation = false
    @State private var showsRenamePrompt = false
    @State private var renameDraft = ""
    @State private var showsAddExercise = false
    @State private var pendingExerciseForSetup: Exercise?
    @State private var customSetCounts: [UUID: Int] = [:]
    @State private var warmupExpanded: Bool = false
    /// Bumped on every successful `completeSet`. Drives the
    /// `.sensoryFeedback(.success, trigger:)` on `WorkoutCommandCard`, so the
    /// haptic lives at the atom layer instead of being fired imperatively
    /// from the view-model. Wraps via `&+=` to stay non-monotonic-safe.
    @State private var setLoggedPhase: Int = 0
    /// Re-entrancy guard. Two ultra-fast "Done" taps inside the same runloop
    /// could fire `completeSet` twice → duplicate `SetEntry` insert, double
    /// `setLoggedPhase` bump, double rest-timer start. Flipped true on entry,
    /// reset on the next runloop tick so legitimate next-set logging works.
    @State private var isLoggingSet: Bool = false
    /// Bumped when a warmup set lands. Lighter haptic than working sets so the
    /// lifter can tell warmup from work without looking.
    @State private var warmupLoggedPhase: Int = 0
    /// Bumped exactly once when the lifter finishes the workout. Drives the
    /// session-finish success notification haptic.
    @State private var workoutFinishedPhase: Int = 0

    /// Plus / minus on the rest timer adjust by this many seconds (minimum rest stays 30s).
    private static let restTimerAdjustStepSeconds = 30

    private var template: DayTemplate? {
        templates.first(where: { $0.id == session.templateId })
    }

    private var workoutNavigationTitle: String {
        (template?.name ?? "Workout").truncatedForNavigationTitle(maxGlyphCount: 34)
    }

    private var isQuickStartSession: Bool {
        template?.name == "Quick Start"
    }

    private var orderedExercises: [Exercise] {
        guard let template else { return [] }
        return template.orderedExerciseIds.compactMap { id in
            exercises.first(where: { $0.id == id })
        }
    }

    private var sectionModels: [WorkoutExerciseSectionModel] {
        orderedExercises.map { exercise in
            let plannedSetCount = plannedSetCount(for: exercise.id)
            let entries = currentEntries(for: exercise.id).filter { !$0.isWarmup }
            let prefill = viewModel.prefillSet(
                for: exercise.id,
                currentSession: session,
                sessions: sessions,
                plannedReps: template?.plannedReps(for: exercise.id)
            )

            return WorkoutExerciseSectionModel(
                exercise: exercise,
                lastActualText: lastActualText(for: exercise),
                entries: entries,
                prefill: prefill,
                plannedSetCount: plannedSetCount
            )
        }
    }

    private var recommendedExerciseIndex: Int {
        guard !sectionModels.isEmpty else { return 0 }
        return sectionModels.firstIndex(where: { !$0.hasReachedPlannedSetGoal }) ?? max(sectionModels.count - 1, 0)
    }

    private var isWorkoutComplete: Bool {
        !sectionModels.isEmpty && sectionModels.allSatisfy(\.hasReachedPlannedSetGoal)
    }

    private var nextSection: WorkoutExerciseSectionModel? {
        guard selectedExerciseIndex < sectionModels.count - 1 else { return nil }
        return sectionModels[selectedExerciseIndex + 1]
    }

    private var currentSection: WorkoutExerciseSectionModel? {
        guard sectionModels.indices.contains(selectedExerciseIndex) else { return nil }
        return sectionModels[selectedExerciseIndex]
    }

    private var primaryButton: PrimaryButtonConfig? {
        guard isWorkoutComplete else { return nil }
        return PrimaryButtonConfig(label: AppCopy.Workout.finishWorkout) {
            showsFinishConfirmation = true
        }
    }

    private var nextExerciseBarState: SessionStateBar.State? {
        guard let nextSection, !isWorkoutComplete else { return nil }
        return .nextExercise(subtitle: nextSection.exercise.displayName)
    }

    private func emptyMetricPlaceholder() -> String {
        let hasAnyCompleted = sessions.contains(where: \.isCompleted)
        if !hasAnyCompleted {
            return AppCopy.EmptyState.noHistoryYet
        }
        return AppCopy.EmptyState.noPriorSets
    }

    /// True while the rest timer is running and ≤ 3 seconds remain.
    /// Drives the final-3s warning haptic on the screen — bound to
    /// `.sensoryFeedback(.warning, trigger:)` with a `false → true` filter so
    /// the haptic fires once when the lifter enters the heads-up window, not
    /// on every tick. Visual treatment is intentionally absent (numeric
    /// countdown already cross-fades; pulse / ring fill is decorative motion).
    private var isRestFinalCountdown: Bool {
        restTimer.isRunning && restTimer.secondsRemaining > 0 && restTimer.secondsRemaining <= 3
    }

    private var timerDisplayText: String {
        if showsReadyState && restTimer.secondsRemaining == 0 && !restTimer.isRunning {
            return "Ready"
        }

        if restTimer.secondsRemaining > 0 {
            return restTimer.label
        }

        let minutes = restDurationSeconds / 60
        let seconds = restDurationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timerControlState: RestTimerControl.State {
        if showsReadyState && restTimer.secondsRemaining == 0 && !restTimer.isRunning {
            return .ready
        }

        if restTimer.isRunning {
            return .running
        }

        if restTimer.secondsRemaining > 0 {
            return .paused
        }

        return .idle
    }

    @ViewBuilder
    private func workoutMainColumn(for section: WorkoutExerciseSectionModel) -> some View {
        VStack(spacing: AppSpacing.lg) {
            if let warmups = warmupSets(for: section),
               !hasLoggedWorkingSet(for: section.exercise.id) {
                WarmupRow(
                    warmups: warmups,
                    completedIndices: completedWarmupIndices(for: section.exercise.id),
                    isBodyweight: section.exercise.isBodyweight,
                    isExpanded: $warmupExpanded,
                    onLog: { warmup in
                        completeWarmup(
                            exercise: section.exercise,
                            warmup: warmup
                        )
                    }
                )
            }

            WorkoutCommandCard(
                progressSteps: progressSteps(for: section),
                exerciseName: section.exercise.displayName,
                metricValue: metricValue(for: section),
                metricSupportingText: metricSupportingText(for: section),
                metricIsHint: metricIsPlaceholder(for: section),
                state: workoutCommandCardState(for: section),
                primaryLabel: AppCopy.Workout.completeSet,
                onPrimaryAction: section.hasReachedPlannedSetGoal ? nil : {
                    completeSuggestedSet(
                        exercise: section.exercise,
                        prefill: section.prefill
                    )
                },
                onSecondaryAction: section.hasReachedPlannedSetGoal ? nil : {
                    adjustResultPayload = AdjustResultPayload(
                        exercise: section.exercise,
                        prefill: section.prefill
                    )
                },
                setLoggedSignal: setLoggedPhase,
                timerValue: timerDisplayText,
                timerState: timerControlState,
                onTimerDecrease: adjustRestTimerAction,
                onTimerToggle: toggleRestTimerAction,
                onTimerIncrease: increaseRestTimerAction
            )

            if isQuickStartSession {
                addExerciseButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func workoutCommandCardState(for section: WorkoutExerciseSectionModel) -> WorkoutCommandCard.State {
        if section.hasReachedPlannedSetGoal {
            return .completed
        }
        return .active
    }

    private func metricValue(for section: WorkoutExerciseSectionModel) -> String {
        if let lastValues = lastLoggedValues(for: section.exercise.id) {
            return WorkoutTargetFormatter.setMetricText(
                weightKg: lastValues.weight,
                reps: lastValues.reps,
                isBodyweight: section.exercise.isBodyweight
            ) ?? emptyMetricPlaceholder()
        }
        if let lastActual = section.lastActualText {
            return lastActual
        }
        return emptyMetricPlaceholder()
    }

    private func metricSupportingText(for section: WorkoutExerciseSectionModel) -> String? {
        if !currentEntries(for: section.exercise.id).isEmpty {
            return nil
        }
        return section.lastActualText != nil ? "Last session" : nil
    }

    private func metricIsPlaceholder(for section: WorkoutExerciseSectionModel) -> Bool {
        if lastLoggedValues(for: section.exercise.id) != nil { return false }
        if section.lastActualText != nil { return false }
        return true
    }

    var body: some View {
        AppScreen(
            primaryButton: primaryButton,
            showsNativeNavigationBar: true
        ) {
            if let currentSection {
                workoutMainColumn(for: currentSection)
            } else {
                addExercisePrompt
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let nextExerciseBarState {
                SessionStateBar(
                    state: nextExerciseBarState,
                    onAdvance: nextSection == nil ? nil : goToNextExerciseAction
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(workoutNavigationTitle)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showsCancelConfirmation = true
                } label: {
                    Label(AppCopy.Nav.close, systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel(AppCopy.Nav.close)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !sectionModels.isEmpty {
                    Button {
                        showLineup = true
                    } label: {
                        Label(AppCopy.Nav.exercises, systemImage: "list.bullet")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel(AppCopy.Nav.exercises)
                }
                if session.setEntries.contains(where: { $0.isCompleted }) && !isWorkoutComplete {
                    Button {
                        showsFinishConfirmation = true
                    } label: {
                        Label(AppCopy.Workout.finishWorkout, systemImage: "checkmark")
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel(AppCopy.Workout.finishWorkout)
                }
            }
        }
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        // Final-3s heads-up: a single warning haptic when the rest countdown
        // enters the ≤3s window while running. No visual emphasis — brand
        // doctrine treats final-seconds pulses / ring fills as decorative,
        // and the haptic survives Reduce Motion (it is permitted tactile
        // feedback). The closure filter fires only on `false → true` so we
        // don't haptic-spam every tick.
        .sensoryFeedback(.warning, trigger: isRestFinalCountdown) { old, new in
            !old && new
        }
        // Rest finished → soft success on transition to ready. Distinct from
        // the warning above so the lifter can hear/feel "now". Filter mirrors
        // the heads-up: only `false → true`.
        .sensoryFeedback(.success, trigger: showsReadyState) { old, new in
            !old && new
        }
        // Warmup logged → light impact (replaces the previous imperative
        // `UIImpactFeedbackGenerator(style: .light)` call). Lighter than the
        // working-set success so the lifter can tell warmup from work without
        // looking at the screen.
        .sensoryFeedback(.impact(weight: .light), trigger: warmupLoggedPhase)
        // Workout finished → notification-style success haptic (replaces the
        // imperative `UINotificationFeedbackGenerator` in `finishWorkout`).
        .sensoryFeedback(.success, trigger: workoutFinishedPhase)
        .sheet(isPresented: $showLineup) {
            exerciseListSheet
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .sheet(isPresented: $showLogs) {
            logsSheet
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .sheet(item: $adjustResultPayload) { payload in
            AdjustResultSheet(
                exerciseName: payload.exercise.displayName,
                isBodyweight: payload.exercise.isBodyweight,
                prefill: payload.prefill
            ) { weight, reps, note in
                completeSet(
                    exercise: payload.exercise,
                    weight: weight,
                    reps: reps,
                    note: note
                )
            }
            .presentationDetents([.medium, .large])
            .appBottomSheetChrome()
        }
        .sheet(isPresented: $showsAddExercise) {
            AddExerciseSheet(
                existingIds: Set(template?.orderedExerciseIds ?? [])
            ) { exercise in
                addExerciseToWorkout(exercise)
            }
            .presentationDetents([.medium, .large])
            .appBottomSheetChrome()
        }
        .sheet(item: $pendingExerciseForSetup) { exercise in
            SetCountPickerSheet(exerciseName: exercise.displayName) { count in
                customSetCounts[exercise.id] = count
            }
            .presentationDetents([.height(320)])
            .appBottomSheetChrome()
        }
        .alert("Cancel Workout", isPresented: $showsCancelConfirmation) {
            Button("Cancel Workout", role: .destructive) {
                cancelWorkout()
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this workout? All logged sets will be lost.")
        }
        .alert("Skip Exercise?", isPresented: $showsSkipExerciseConfirmation) {
            Button("Skip", role: .destructive) {
                goToNextExercise()
            }
            Button("Keep Logging", role: .cancel) {}
        } message: {
            if let currentSection {
                let remaining = currentSection.plannedSetCount - currentSection.entries.count
                Text("You have \(remaining) unlogged set\(remaining == 1 ? "" : "s") for \(currentSection.exercise.displayName).")
            }
        }
        .alert("Finish workout", isPresented: $showsFinishConfirmation) {
            Button(AppCopy.Workout.finishWorkout) {
                finishWorkout()
                if template?.name == "Quick Start" {
                    renameDraft = ""
                    showsRenamePrompt = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will finish and save your session.")
        }
        .alert("Name this workout", isPresented: $showsRenamePrompt) {
            TextField("Workout name", text: $renameDraft)
            Button(AppCopy.Session.useName) {
                let trimmed = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                if let template, !trimmed.isEmpty {
                    template.name = trimmed
                    try? modelContext.save()
                }
            }
            Button(AppCopy.Session.skipNaming, role: .cancel) {}
        } message: {
            Text("Give this session a name so you can find it later.")
        }
        .onAppear {
            selectedExerciseIndex = recommendedExerciseIndex
        }
        .onChange(of: sectionModels.count) { _, newValue in
            guard newValue > 0 else {
                selectedExerciseIndex = 0
                return
            }
            selectedExerciseIndex = min(selectedExerciseIndex, newValue - 1)
        }
        .onChange(of: restTimer.completionCount) { _, newValue in
            guard newValue > 0 else { return }
            showsReadyState = true
        }
        .onDisappear {
            restTimer.stop()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, restTimer.endDate != nil {
                restTimer.resumeFromBackground()
            }
        }
    }

    private var addExercisePrompt: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                Text("Add your first exercise")
                    .font(AppFont.productHeading.font)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Search existing exercises or create a new one.")
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)

                AppPrimaryButton("Add Exercise") {
                    showsAddExercise = true
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var addExerciseButton: some View {
        AppGhostButton("Add Exercise") {
            showsAddExercise = true
        }
    }

    private var exerciseListSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(exerciseLineupFragments) { fragment in
                        switch fragment {
                        case .grouped(let pairs):
                            AppCardList(data: pairs.map { LineupRowItem(index: $0.index, section: $0.section) }, id: \.id) { item in
                                Button {
                                    selectedExerciseIndex = item.index
                                    showLineup = false
                                } label: {
                                    exerciseLineupRowContent(index: item.index, section: item.section)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .accessibilityLabel(
                                    exerciseLineupAccessibilityLabel(
                                        name: item.section.exercise.displayName,
                                        isCurrent: item.index == selectedExerciseIndex,
                                        isDone: item.section.hasReachedPlannedSetGoal
                                    )
                                )
                            }
                        case .rich(let index, let section):
                            AppCardList(data: [LineupRowItem(index: index, section: section)], id: \.id) { item in
                                Button {
                                    selectedExerciseIndex = item.index
                                    showLineup = false
                                } label: {
                                    exerciseLineupRowContent(index: item.index, section: item.section)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .accessibilityLabel(
                                    exerciseLineupAccessibilityLabel(
                                        name: item.section.exercise.displayName,
                                        isCurrent: item.index == selectedExerciseIndex,
                                        isDone: item.section.hasReachedPlannedSetGoal
                                    )
                                )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.md)
            }
            .appScrollEdgeSoft()
            .navigationTitle(AppCopy.Nav.exercises)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showLineup = false
                    }
                    .appToolbarTextStyle()
                }
            }
            .appNavigationBarChrome()
        }
        .background(AppColor.background.ignoresSafeArea())
    }

    private struct LineupRowItem {
        let index: Int
        let section: WorkoutExerciseSectionModel
        var id: UUID { section.id }
    }

    private enum ExerciseLineupFragment: Identifiable {
        case grouped([(index: Int, section: WorkoutExerciseSectionModel)])
        case rich(index: Int, section: WorkoutExerciseSectionModel)

        var id: String {
            switch self {
            case .grouped(let pairs):
                "g-" + pairs.map { "\($0.index)-\($0.section.id.uuidString)" }.joined(separator: "|")
            case .rich(let index, let section):
                "r-\(index)-\(section.id.uuidString)"
            }
        }
    }

    /// Name-only rows are merged into one card with hairlines; rows with last-session subtitle stay on their own card.
    private var exerciseLineupFragments: [ExerciseLineupFragment] {
        var result: [ExerciseLineupFragment] = []
        var nameOnlyRun: [(index: Int, section: WorkoutExerciseSectionModel)] = []

        func flushRun() {
            guard !nameOnlyRun.isEmpty else { return }
            result.append(.grouped(nameOnlyRun))
            nameOnlyRun = []
        }

        for (index, section) in sectionModels.enumerated() {
            if exerciseListSubtitle(for: section) != nil {
                flushRun()
                result.append(.rich(index: index, section: section))
            } else {
                nameOnlyRun.append((index: index, section: section))
            }
        }
        flushRun()
        return result
    }

    @ViewBuilder
    private func exerciseLineupRowContent(index: Int, section: WorkoutExerciseSectionModel) -> some View {
        let isCurrent = index == selectedExerciseIndex
        let isDone = section.hasReachedPlannedSetGoal

        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(section.exercise.displayName)
                    .font(AppFont.productAction.font)
                    .foregroundStyle(isDone ? AppColor.textSecondary : AppColor.textPrimary)
                    .multilineTextAlignment(.leading)

                if let subtitle = exerciseListSubtitle(for: section) {
                    Text(subtitle)
                        .font(AppFont.productAction.font)
                        .foregroundStyle(isDone ? AppColor.controlBackground : AppColor.textSecondary)
                }
            }

            Spacer(minLength: 0)

            if isCurrent && !isDone {
                AppTag(text: "Current", style: .accent)
            } else if isDone {
                ZStack {
                    Circle()
                        .fill(AppColor.success.opacity(0.1))
                        .frame(width: 24, height: 24)

                    AppIcon.checkmark.image(size: 12, weight: .bold)
                        .foregroundStyle(AppColor.success)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpacing.md)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
    }

    private func exerciseListSubtitle(for section: WorkoutExerciseSectionModel) -> String? {
        section.lastActualText
    }

    private func exerciseLineupAccessibilityLabel(name: String, isCurrent: Bool, isDone: Bool) -> String {
        if isDone { return "\(name), completed" }
        if isCurrent { return "\(name), current exercise" }
        return name
    }

    private var logsSheet: some View {
        NavigationStack {
            Group {
                if let currentSection {
                    ScrollView {
                        AppCardList(data: Array(0..<currentSection.plannedSetCount), id: \.self) { index in
                            logsSheetRow(index: index, section: currentSection)
                        }
                    }
                    .appScrollEdgeSoft()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle(AppCopy.Nav.logs)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showLogs = false
                    }
                    .appToolbarTextStyle()
                }
            }
            .appNavigationBarChrome()
        }
    }

    @ViewBuilder
    private func logsSheetRow(index: Int, section: WorkoutExerciseSectionModel) -> some View {
        let entry = index < section.entries.count ? section.entries[index] : nil
        let isCurrent = !section.hasReachedPlannedSetGoal && index == section.entries.count
        let isDone = entry != nil

        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Set \(index + 1)")
                    .font(AppFont.productAction.font)
                    .foregroundStyle(isDone ? AppColor.textSecondary : AppColor.textPrimary)

                if let entry {
                    Text(logEntrySubtitle(for: entry, exercise: section.exercise))
                        .font(AppFont.productAction.font)
                        .foregroundStyle(AppColor.controlBackground)
                }
            }

            Spacer(minLength: 0)

            if isDone {
                AppIconCircle(diameter: 32) {
                    AppIcon.checkmark.image(size: 14, weight: .semibold)
                        .foregroundStyle(AppColor.textPrimary)
                }
            } else if isCurrent {
                AppTag(text: "Current", style: .accent)
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .frame(minHeight: 72)
        .contentShape(Rectangle())
    }

    private func logEntrySubtitle(for entry: SetEntry, exercise: Exercise) -> String {
        WorkoutTargetFormatter.setMetricText(
            weightKg: entry.weight,
            reps: entry.reps,
            isBodyweight: exercise.isBodyweight
        ) ?? "\(entry.reps)"
    }

    private func lastLoggedValues(for exerciseID: UUID) -> (weight: Double, reps: Int)? {
        let entries = currentEntries(for: exerciseID).filter { !$0.isWarmup }
        guard let last = entries.last else { return nil }
        return (last.weight, last.reps)
    }

    private func currentEntries(for exerciseID: UUID) -> [SetEntry] {
        session.setEntries
            .filter { $0.exerciseId == exerciseID }
            .sorted { $0.setIndex < $1.setIndex }
    }

    private func progressSteps(for section: WorkoutExerciseSectionModel) -> [SetProgressIndicator.Step] {
        (0..<section.plannedSetCount).map { index in
            let state: SetProgressIndicator.Step.State
            var reps: Int?
            var weightText: String?

            if index < section.entries.count {
                let entry = section.entries[index]
                state = .completed
                reps = entry.reps
                if section.exercise.isBodyweight {
                    weightText = "BW"
                } else if entry.weight > 0 {
                    weightText = WorkoutTargetFormatter.weightCompact(entry.weight)
                }
            } else if !section.hasReachedPlannedSetGoal && index == section.entries.count {
                state = .current
            } else {
                state = .upcoming
            }

            return SetProgressIndicator.Step(
                id: index,
                label: "\(index + 1)",
                state: state,
                reps: reps,
                weightText: weightText
            )
        }
    }

    private func nextSetHelperText(for section: WorkoutExerciseSectionModel) -> String? {
        guard !section.hasReachedPlannedSetGoal else { return nil }
        let nextSetNumber = min(section.entries.count + 1, section.plannedSetCount)
        return "Next: Set \(nextSetNumber)"
    }

    private var adjustRestTimerAction: (() -> Void)? {
        guard currentSection != nil, !isWorkoutComplete else { return nil }
        return { adjustRestTimer(by: -Self.restTimerAdjustStepSeconds) }
    }

    private var increaseRestTimerAction: (() -> Void)? {
        guard currentSection != nil, !isWorkoutComplete else { return nil }
        return { adjustRestTimer(by: Self.restTimerAdjustStepSeconds) }
    }

    private var toggleRestTimerAction: (() -> Void)? {
        guard currentSection != nil, !isWorkoutComplete else { return nil }
        return { toggleRestTimer() }
    }

    private var goToNextExerciseAction: (() -> Void)? {
        guard nextSection != nil else { return nil }
        return {
            if let currentSection, !currentSection.hasReachedPlannedSetGoal {
                showsSkipExerciseConfirmation = true
            } else {
                goToNextExercise()
            }
        }
    }

    private func lastActualText(for exercise: Exercise) -> String? {
        guard let lastSession = sessions.first(where: {
            $0.id != session.id &&
            $0.isCompleted &&
            $0.setEntries.contains(where: { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup })
        }) else {
            return nil
        }

        let sets = lastSession.setEntries
            .filter { $0.exerciseId == exercise.id && $0.isCompleted && !$0.isWarmup }
            .sorted { $0.setIndex < $1.setIndex }

        return sets.last.map {
            WorkoutTargetFormatter.lastText(
                weightKg: $0.weight,
                setCount: sets.count,
                reps: $0.reps,
                isBodyweight: exercise.isBodyweight
            )
        }
    }

    private func toggleRestTimer() {
        if restTimer.isRunning {
            restTimer.pause()
            return
        }

        if restTimer.secondsRemaining > 0 {
            restTimer.resume()
        } else {
            startRestTimer(seconds: restDurationSeconds)
        }
    }

    private func startRestTimer(seconds: Int) {
        showsReadyState = false
        restDurationSeconds = max(30, seconds)
        restTimer.start(totalSeconds: restDurationSeconds)
    }

    private func adjustRestTimer(by delta: Int) {
        if restTimer.secondsRemaining > 0 {
            showsReadyState = false
            restTimer.adjust(by: delta, minimumSeconds: 30)
            restDurationSeconds = max(30, restTimer.totalDuration)
        } else {
            restDurationSeconds = max(30, restDurationSeconds + delta)
        }
    }

    private func goToNextExercise() {
        guard selectedExerciseIndex < sectionModels.count - 1 else { return }
        showsReadyState = false
        restTimer.stop()
        withAnimation(reduceMotion ? nil : .appExit) {
            selectedExerciseIndex += 1
        }
    }

    private func completeSuggestedSet(
        exercise: Exercise,
        prefill: SetPrefill?
    ) {
        if let prefill, prefill.source != .planned {
            completeSet(
                exercise: exercise,
                weight: prefill.weight,
                reps: prefill.reps
            )
            return
        }

        adjustResultPayload = AdjustResultPayload(
            exercise: exercise,
            prefill: prefill
        )
    }

    private func completeSet(
        exercise: Exercise,
        weight: Double,
        reps: Int,
        note: String = ""
    ) {
        guard !isLoggingSet else { return }
        isLoggingSet = true
        DispatchQueue.main.async { isLoggingSet = false }

        let setIndex = currentEntries(for: exercise.id).count

        let entry = SetEntry(
            sessionId: session.id,
            exerciseId: exercise.id,
            weight: weight,
            reps: reps,
            rpe: 0,
            rir: -1,
            isWarmup: false,
            isCompleted: true,
            setIndex: setIndex,
            note: note
        )
        entry.session = session

        // The metric value displayed by `WorkoutCommandCard` reads through
        // `currentEntries`, which mutates as soon as we insert. Wrapping the
        // insertion in `withAnimation` lets SwiftUI propagate the transaction
        // through `@Query` re-renders, so the card's `.contentTransition(.numericText())`
        // engages — the next prefill weight × reps cross-fades into view
        // instead of flickering. `nil` under Reduce Motion preserves the
        // mutation but skips the cross-fade.
        withAnimation(reduceMotion ? nil : .appReveal) {
            modelContext.insert(entry)
            try? modelContext.save()
            showsReadyState = false
        }

        // Trigger the success haptic on `WorkoutCommandCard` via the bound
        // `setLoggedSignal` (replaces the previous raw UIKit impact). The
        // haptic fires regardless of Reduce Motion — accessibility doctrine
        // explicitly permits tactile feedback.
        setLoggedPhase &+= 1

        let completedWorkingSetCount = currentEntries(for: exercise.id)
            .filter { !$0.isWarmup }
            .count
        let plannedCount = plannedSetCount(for: exercise.id)

        if completedWorkingSetCount >= plannedCount {
            restTimer.stop()
        } else {
            startRestTimer(seconds: restDurationSeconds)
        }
    }

    private func completeWarmup(
        exercise: Exercise,
        warmup: WarmupGenerator.WarmupSet
    ) {
        let setIndex = session.setEntries
            .filter { $0.exerciseId == exercise.id }
            .count

        let entry = SetEntry(
            sessionId: session.id,
            exerciseId: exercise.id,
            weight: warmup.weightKg,
            reps: warmup.reps,
            rpe: 0,
            rir: -1,
            isWarmup: true,
            isCompleted: true,
            setIndex: setIndex,
            note: ""
        )
        entry.session = session
        modelContext.insert(entry)
        try? modelContext.save()
        warmupLoggedPhase &+= 1
    }

    private func warmupSets(
        for section: WorkoutExerciseSectionModel
    ) -> [WarmupGenerator.WarmupSet]? {
        guard let prefill = section.prefill else { return nil }
        return WarmupGenerator.warmups(
            forWorkingKg: prefill.weight,
            isBodyweight: section.exercise.isBodyweight
        )
    }

    private func hasLoggedWorkingSet(for exerciseID: UUID) -> Bool {
        session.setEntries.contains { entry in
            entry.exerciseId == exerciseID
                && entry.isCompleted
                && !entry.isWarmup
        }
    }

    private func completedWarmupIndices(for exerciseID: UUID) -> Set<Int> {
        let warmups = session.setEntries
            .filter { $0.exerciseId == exerciseID && $0.isWarmup && $0.isCompleted }
            .sorted { $0.setIndex < $1.setIndex }
        // Map in order: the first completed warmup corresponds to index 0, etc.
        return Set(warmups.indices)
    }

    private func finishWorkout() {
        restTimer.stop()
        session.isCompleted = true
        try? modelContext.save()
        workoutFinishedPhase &+= 1
    }

    private func addExerciseToWorkout(_ exercise: Exercise) {
        guard let template else { return }
        var ids = template.orderedExerciseIds
        guard !ids.contains(exercise.id) else { return }
        ids.append(exercise.id)
        template.orderedExerciseIds = ids
        try? modelContext.save()
        selectedExerciseIndex = ids.count - 1
        pendingExerciseForSetup = exercise
    }

    private func cancelWorkout() {
        restTimer.stop()
        modelContext.delete(session)
        try? modelContext.save()
    }

    private func plannedSetCount(for exerciseID: UUID) -> Int {
        if let custom = customSetCounts[exerciseID] {
            return custom
        }
        if let latestTemplateCount = latestCompletedSetCount(for: exerciseID, matchingTemplate: true) {
            return latestTemplateCount
        }
        if let latestAnyCount = latestCompletedSetCount(for: exerciseID, matchingTemplate: false) {
            return latestAnyCount
        }
        if let templatePlan = template?.plannedSets(for: exerciseID), templatePlan > 0 {
            return templatePlan
        }
        return 3
    }

    private func latestCompletedSetCount(for exerciseID: UUID, matchingTemplate: Bool) -> Int? {
        let candidates = sessions.filter { candidate in
            candidate.id != session.id &&
            candidate.isCompleted &&
            (!matchingTemplate || candidate.templateId == session.templateId) &&
            candidate.setEntries.contains(where: {
                $0.exerciseId == exerciseID &&
                $0.isCompleted &&
                !$0.isWarmup
            })
        }

        guard let latest = candidates.max(by: { $0.date < $1.date }) else {
            return nil
        }

        let setCount = latest.setEntries.filter {
            $0.exerciseId == exerciseID &&
            $0.isCompleted &&
            !$0.isWarmup
        }.count

        return setCount > 0 ? setCount : nil
    }
}

private struct WorkoutExerciseSectionModel: Identifiable {
    let exercise: Exercise
    let lastActualText: String?
    let entries: [SetEntry]
    let prefill: SetPrefill?
    let plannedSetCount: Int

    var id: UUID { exercise.id }

    var hasReachedPlannedSetGoal: Bool {
        entries.count >= plannedSetCount
    }
}

private struct AdjustResultPayload: Identifiable {
    let exercise: Exercise
    let prefill: SetPrefill?

    var id: UUID { exercise.id }
}

private struct AdjustResultSheet: View {
    let exerciseName: String
    let isBodyweight: Bool
    let prefill: SetPrefill?
    let onSave: (_ weight: Double, _ reps: Int, _ note: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var weightText = ""
    @State private var repsText = ""
    @State private var noteText = ""
    @State private var seeded = false

    private var parsedWeight: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var parsedReps: Int {
        Int(repsText) ?? 0
    }

    private var effectiveIsBodyweight: Bool {
        isBodyweight || (!isBodyweight && parsedWeight == 0 && !weightText.isEmpty)
    }

    private var canSave: Bool {
        parsedReps > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.sm) {
                        manualInputField(
                            title: isBodyweight ? "Weight" : "Weight (kg)",
                            text: $weightText,
                            keyboardType: .decimalPad,
                            suffix: effectiveIsBodyweight ? "BW" : nil
                        )

                        manualInputField(
                            title: "Reps",
                            text: $repsText,
                            keyboardType: .numberPad
                        )
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(AppCopy.Workout.adjustSetNoteLabel)
                            .font(AppFont.sectionHeader.font)
                            .foregroundStyle(AppColor.textPrimary)

                        TextField(
                            AppCopy.Workout.adjustSetNotePlaceholder,
                            text: $noteText,
                            axis: .vertical
                        )
                        .font(AppFont.body.font)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3...5)
                        .appInputFieldStyleMultiline(
                            minHeight: 96,
                            horizontalPadding: AppSpacing.md,
                            verticalPadding: AppSpacing.smd,
                            elevated: true
                        )
                    }
                    .padding(.top, AppSpacing.md)

                    AppPrimaryButton(AppCopy.Workout.completeSet, isEnabled: canSave) {
                        onSave(effectiveIsBodyweight ? 0 : parsedWeight, parsedReps, noteText)
                        dismiss()
                    }
                    .padding(.top, AppSpacing.md)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .appNavigationBarChrome()
        }
        .onAppear {
            guard !seeded else { return }
            seeded = true
            guard let prefill else { return }
            if !isBodyweight, prefill.weight > 0 {
                weightText = prefill.weight.weightString
            }
            repsText = "\(prefill.reps)"
        }
    }

    @ViewBuilder
    private func manualInputField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        suffix: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                TextField("0", text: text)
                    .keyboardType(keyboardType)
                    .font(AppFont.numericDisplay.font)
                    .multilineTextAlignment(.center)

                if let suffix {
                    Text(suffix)
                        .font(AppFont.productAction.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .appInputFieldStyle(height: 64, horizontalPadding: AppSpacing.sm, elevated: true)
        }
    }
}

private struct SetCountPickerSheet: View {
    let exerciseName: String
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCount = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.md) {
                    Text("How many sets?")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: AppSpacing.sm) {
                        ForEach(1...6, id: \.self) { count in
                            Button {
                                selectedCount = count
                            } label: {
                                Text("\(count)")
                                    .font(AppFont.sectionHeader.font)
                                    .foregroundStyle(count == selectedCount ? AppColor.accentForeground : AppColor.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(count == selectedCount ? AppColor.accent : AppColor.controlBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }

                AppPrimaryButton(AppCopy.Workout.continueWorkout) {
                    onSelect(selectedCount)
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .appNavigationBarChrome()
        }
    }
}

private struct AddExerciseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    let existingIds: Set<UUID>
    let onSelect: (Exercise) -> Void

    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredExercises: [Exercise] {
        let available = exercises.filter { !existingIds.contains($0.id) }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return available }
        let needle = trimmed.lowercased()
        return available.filter { exercise in
            exercise.displayName.lowercased().contains(needle) ||
            exercise.aliases.contains { $0.lowercased().contains(needle) }
        }
    }

    private var canCreateNew: Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return !exercises.contains { $0.displayName.lowercased() == trimmed.lowercased() }
    }

    var body: some View {
        NavigationStack {
            List {
                if canCreateNew {
                    Button {
                        createAndSelect(name: query.trimmingCharacters(in: .whitespacesAndNewlines))
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            AppIcon.addCircle.image()
                                .foregroundStyle(AppColor.accent)
                            Text("Create \"\(query.trimmingCharacters(in: .whitespacesAndNewlines))\"")
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textPrimary)
                        }
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .listRowBackground(AppColor.cardBackground)
                }

                ForEach(filteredExercises, id: \.id) { exercise in
                    Button {
                        onSelect(exercise)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.sm) {
                                Text(exercise.displayName)
                                    .font(AppFont.body.font)
                                    .foregroundStyle(AppColor.textPrimary)
                                if exercise.isBodyweight {
                                    Text("BW")
                                        .font(AppFont.caption.font)
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                            if !exercise.aliases.isEmpty {
                                Text(exercise.aliases.joined(separator: " · "))
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .listRowBackground(AppColor.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.sheetBackground.ignoresSafeArea())
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search or create new")
            .searchFocused($isSearchFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .onSubmit(of: .search) {
                guard canCreateNew else { return }
                createAndSelect(name: query.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .appToolbarTextStyle()
                }
            }
            .appNavigationBarChrome()
            .tint(AppColor.accent)
            .onAppear { isSearchFocused = true }
        }
    }

    private func createAndSelect(name: String) {
        let exercise = Exercise(displayName: name)
        modelContext.insert(exercise)
        try? modelContext.save()
        onSelect(exercise)
        dismiss()
    }
}

struct SetPrefill {
    enum Source {
        case currentSession
        case priorSession
        case planned
    }

    let weight: Double
    let reps: Int
    let source: Source
}

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    func prefillSet(
        for exerciseID: UUID,
        currentSession: WorkoutSession,
        sessions: [WorkoutSession],
        plannedReps: Int? = nil
    ) -> SetPrefill? {
        let currentEntries = currentSession.setEntries
            .filter { $0.exerciseId == exerciseID }
            .sorted { $0.setIndex < $1.setIndex }

        if let currentLast = currentEntries.last {
            return SetPrefill(
                weight: currentLast.weight,
                reps: currentLast.reps,
                source: .currentSession
            )
        }

        if let reference = latestSessionSet(
            for: exerciseID,
            currentSession: currentSession,
            sessions: sessions
        ) {
            return SetPrefill(
                weight: reference.weight,
                reps: reference.reps,
                source: .priorSession
            )
        }

        if let plannedReps, plannedReps > 0 {
            return SetPrefill(weight: 0, reps: plannedReps, source: .planned)
        }

        return nil
    }

    private func latestSessionSet(
        for exerciseID: UUID,
        currentSession: WorkoutSession,
        sessions: [WorkoutSession]
    ) -> SetEntry? {
        guard let session = latestSession(
            for: exerciseID,
            currentSession: currentSession,
            sessions: sessions
        ) else {
            return nil
        }

        return session.setEntries
            .filter { $0.exerciseId == exerciseID && $0.isCompleted }
            .sorted { $0.setIndex < $1.setIndex }
            .last
    }

    private func latestSession(
        for exerciseID: UUID,
        currentSession: WorkoutSession,
        sessions: [WorkoutSession]
    ) -> WorkoutSession? {
        sessions.first { session in
            session.id != currentSession.id &&
            session.isCompleted &&
            session.setEntries.contains(where: { $0.exerciseId == exerciseID && $0.isCompleted })
        }
    }
}

@MainActor
@Observable
final class RestTimerManager {
    var secondsRemaining = 0
    var isRunning = false
    var completionCount = 0
    private(set) var totalDuration = 0

    private var task: Task<Void, Never>?
    private var activity: Activity<RestTimerAttributes>?
    private(set) var endDate: Date?

    /// Persisted across app launches so a force-quit during rest doesn't
    /// desync the in-app timer from the Live Activity (compass: timer follows
    /// the user, including outside the app).
    private static let endDateKey = "unit.restTimer.endDate"
    private static let totalDurationKey = "unit.restTimer.totalDuration"

    init() {
        restoreFromPersistedState()
    }

    var label: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func start(totalSeconds: Int) {
        stop()
        totalDuration = totalSeconds
        secondsRemaining = totalSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        isRunning = true
        persistState()
        startActivity()
        startCountdownTask()
    }

    func pause() {
        guard isRunning, secondsRemaining > 0 else { return }
        task?.cancel()
        task = nil
        isRunning = false
        endDate = nil
        clearPersistedState()
        endActivity()
    }

    func resume() {
        guard !isRunning, secondsRemaining > 0 else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
        persistState()
        startActivity()
        startCountdownTask()
    }

    func resumeFromBackground() {
        guard let end = endDate else { return }
        let remaining = Int(ceil(end.timeIntervalSinceNow))
        if remaining <= 0 {
            completeIfFinished()
        } else {
            secondsRemaining = remaining
            isRunning = true
            startCountdownTask()
        }
    }

    func adjust(by delta: Int, minimumSeconds: Int = 30) {
        let baseRemaining = secondsRemaining > 0 ? secondsRemaining : totalDuration
        let updatedRemaining = max(minimumSeconds, baseRemaining + delta)
        let updatedTotal = max(minimumSeconds, totalDuration + delta)

        secondsRemaining = updatedRemaining
        totalDuration = updatedTotal

        if isRunning {
            endDate = Date().addingTimeInterval(TimeInterval(updatedRemaining))
            persistState()
            updateActivity()
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
        secondsRemaining = 0
        totalDuration = 0
        endDate = nil
        clearPersistedState()
        endActivity()
    }

    private func completeIfFinished() {
        secondsRemaining = 0
        isRunning = false
        totalDuration = 0
        endDate = nil
        completionCount += 1
        clearPersistedState()
        endActivity()
    }

    /// Reconstruct timer state on init from UserDefaults; if defaults are
    /// empty (e.g. after a reinstall mid-rest) fall back to the live Activity.
    private func restoreFromPersistedState() {
        let defaults = UserDefaults.standard
        var recoveredEnd: Date?
        var recoveredTotal: Int = 0

        if let stored = defaults.object(forKey: Self.endDateKey) as? Date {
            recoveredEnd = stored
            recoveredTotal = defaults.integer(forKey: Self.totalDurationKey)
        } else if let liveActivity = Activity<RestTimerAttributes>.activities.first {
            recoveredEnd = liveActivity.content.state.endDate
            recoveredTotal = max(30, Int(liveActivity.content.state.endDate.timeIntervalSinceNow))
            activity = liveActivity
        }

        guard let end = recoveredEnd else { return }
        let remaining = Int(ceil(end.timeIntervalSinceNow))
        if remaining <= 0 {
            // Timer expired while the app was killed — surface the Ready state.
            clearPersistedState()
            completionCount += 1
            return
        }

        endDate = end
        secondsRemaining = remaining
        totalDuration = max(remaining, recoveredTotal)
        isRunning = true
        startCountdownTask()
    }

    private func persistState() {
        let defaults = UserDefaults.standard
        if let endDate {
            defaults.set(endDate, forKey: Self.endDateKey)
            defaults.set(totalDuration, forKey: Self.totalDurationKey)
        } else {
            clearPersistedState()
        }
    }

    private func clearPersistedState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Self.endDateKey)
        defaults.removeObject(forKey: Self.totalDurationKey)
    }

    private func startCountdownTask() {
        task?.cancel()
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let manager = self, let end = manager.endDate else { return }

                let remaining = Int(ceil(end.timeIntervalSinceNow))
                if remaining <= 0 {
                    manager.completeIfFinished()
                    return
                }

                manager.secondsRemaining = remaining
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    private func startActivity() {
        guard let endDate else { return }
        let attributes = RestTimerAttributes()
        let state = RestTimerAttributes.ContentState(endDate: endDate)
        let content = ActivityContent(state: state, staleDate: endDate.addingTimeInterval(60))
        activity = try? Activity<RestTimerAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    private func updateActivity() {
        guard let endDate else { return }
        let updatedState = RestTimerAttributes.ContentState(endDate: endDate)
        let updatedContent = ActivityContent(state: updatedState, staleDate: endDate.addingTimeInterval(60))
        let currentActivity = activity
        Task { @MainActor in
            await currentActivity?.update(updatedContent)
        }
    }

    private func endActivity() {
        let currentActivity = activity
        activity = nil

        Task {
            await currentActivity?.end(nil, dismissalPolicy: .immediate)
        }
    }
}

// MARK: - Warmup row

private struct WarmupRow: View {
    let warmups: [WarmupGenerator.WarmupSet]
    let completedIndices: Set<Int>
    let isBodyweight: Bool
    @Binding var isExpanded: Bool
    let onLog: (WarmupGenerator.WarmupSet) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(reduceMotion ? nil : .appState) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Text("Warmup")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                    Text("· \(warmups.count) set\(warmups.count == 1 ? "" : "s")")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer(minLength: 0)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(warmups) { warmup in
                        WarmupSetButton(
                            warmup: warmup,
                            isDone: completedIndices.contains(warmup.index),
                            onTap: { onLog(warmup) }
                        )
                        if warmup.id != warmups.last?.id {
                            Rectangle()
                                .fill(AppColor.border)
                                .frame(height: 1)
                                .padding(.leading, AppSpacing.md)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColor.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColor.border, lineWidth: 0.5)
        )
    }
}

private struct WarmupSetButton: View {
    let warmup: WarmupGenerator.WarmupSet
    let isDone: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(AppFont.caption.font)
                    .foregroundStyle(isDone ? AppColor.textPrimary : AppColor.textSecondary)
                Text(
                    WorkoutTargetFormatter.setMetricText(
                        weightKg: warmup.weightKg,
                        reps: warmup.reps,
                        isBodyweight: false
                    ) ?? "\(warmup.reps)"
                )
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer(minLength: 0)
                Text("Set \(warmup.index + 1)")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isDone)
    }
}
