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
    @Query private var progressionRules: [ProgressionRule]
    @Query private var cycles: [Cycle]

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

    /// Plus / minus on the rest timer adjust by this many seconds (minimum rest stays 30s).
    private static let restTimerAdjustStepSeconds = 30

    private var template: DayTemplate? {
        templates.first(where: { $0.id == session.templateId })
    }

    private var isQuickStartSession: Bool {
        template?.name == "Quick Start"
    }

    private var activeCycle: Cycle? {
        guard let cycleID = session.cycleId else { return nil }
        return cycles.first(where: { $0.id == cycleID })
    }

    private var orderedExercises: [Exercise] {
        guard let template else { return [] }
        return template.orderedExerciseIds.compactMap { id in
            exercises.first(where: { $0.id == id })
        }
    }

    private var sectionModels: [WorkoutExerciseSectionModel] {
        orderedExercises.map { exercise in
            let rule = progressionRules.first {
                $0.exerciseId == exercise.id && $0.cycleId == session.cycleId
            }
            let weekTarget = viewModel.target(
                for: session.weekNumber,
                rule: rule,
                cycle: activeCycle,
                sessions: sessions
            )
            let plannedSetCount = plannedSetCount(for: exercise.id)
            let targetText = weekTarget.flatMap {
                WorkoutTargetFormatter.setMetricText(
                    weightKg: $0.weightKg,
                    reps: $0.reps,
                    isBodyweight: exercise.isBodyweight
                )
            }
            let entries = currentEntries(for: exercise.id)
            let prefill = viewModel.prefillSet(
                for: exercise.id,
                currentSession: session,
                sessions: sessions,
                rule: rule,
                cycle: activeCycle
            )

            return WorkoutExerciseSectionModel(
                exercise: exercise,
                rule: rule,
                weekTarget: weekTarget,
                targetText: targetText,
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
        return PrimaryButtonConfig(label: "Finish Session") {
            showsFinishConfirmation = true
        }
    }

    private var nextExerciseBarState: SessionStateBar.State? {
        guard let nextSection, !isWorkoutComplete else { return nil }
        return .nextExercise(subtitle: nextSection.exercise.displayName)
    }

    private var currentMetricValue: String {
        guard let currentSection else { return "" }

        if let target = currentSection.weekTarget {
            if currentSection.exercise.isBodyweight {
                return "\(target.reps) x BW"
            }

            if target.weightKg > 0 {
                return "\(target.reps) x \(WorkoutTargetFormatter.weightDisplay(target.weightKg))"
            }
        }

        // Show values from previous set in this session
        if let lastValues = lastLoggedValues(for: currentSection.exercise.id) {
            if currentSection.exercise.isBodyweight {
                return "\(lastValues.reps) x BW"
            }
            return "\(lastValues.reps) x \(WorkoutTargetFormatter.weightDisplay(lastValues.weight))"
        }

        if let lastActual = currentSection.lastActualText {
            return lastActual
        }
        return "Log your set"
    }

    private var currentMetricSupportingText: String? {
        guard let currentSection else { return nil }

        if currentSection.targetText == nil {
            if !currentEntries(for: currentSection.exercise.id).isEmpty {
                return nil
            }
            return currentSection.lastActualText != nil ? "Last session" : nil
        }

        if currentSection.hasReachedPlannedSetGoal {
            return nextSection == nil
                ? "All sets logged. Finish the session."
                : "All sets logged. Move on when ready."
        }

        return nil
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

    private var commandCardState: ExerciseCommandCard.State {
        guard let currentSection else { return .disabled }
        if currentSection.hasReachedPlannedSetGoal {
            return .completed
        }
        return .active
    }

    private var workoutCommandCardState: WorkoutCommandCard.State {
        switch commandCardState {
        case .active:
            return .active
        case .completed:
            return .completed
        case .disabled:
            return .disabled
        }
    }

    var body: some View {
        AppScreen(
            primaryButton: primaryButton,
            showsNativeNavigationBar: true
        ) {
            if let currentSection {
                VStack(spacing: AppSpacing.lg) {
                    WorkoutCommandCard(
                        progressSteps: progressSteps(for: currentSection),
                        exerciseName: currentSection.exercise.displayName,
                        metricValue: currentMetricValue,
                        metricSupportingText: currentMetricSupportingText,
                        state: workoutCommandCardState,
                        primaryLabel: "Log",
                        onPrimaryAction: currentSection.hasReachedPlannedSetGoal ? nil : {
                            completeSuggestedSet(
                                exercise: currentSection.exercise,
                                rule: currentSection.rule,
                                target: currentSection.weekTarget,
                                prefill: currentSection.prefill
                            )
                        },
                        onSecondaryAction: currentSection.hasReachedPlannedSetGoal ? nil : {
                            adjustResultPayload = AdjustResultPayload(
                                exercise: currentSection.exercise,
                                rule: currentSection.rule,
                                prefill: currentSection.prefill
                            )
                        },
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
            } else {
                addExercisePrompt
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let nextExerciseBarState {
                VStack(spacing: 0) {
                    ScrollEdgeFadeView(
                        edge: .topOfFooter,
                        surfaceColor: AppColor.barBackground
                    )

                    SessionStateBar(
                        state: nextExerciseBarState,
                        onAdvance: nextSection == nil ? nil : goToNextExerciseAction
                    )
                }
            }
        }
        .navigationTitle(template?.name ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showsCancelConfirmation = true
                } label: {
                    Image(systemName: AppIcon.close.systemName)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !sectionModels.isEmpty {
                    Button {
                        showLineup = true
                    } label: {
                        Image(systemName: AppIcon.list.systemName)
                    }
                }
                if session.setEntries.contains(where: { $0.isCompleted }) && !isWorkoutComplete {
                    Button {
                        showsFinishConfirmation = true
                    } label: {
                        Image(systemName: AppIcon.checkmark.systemName)
                    }
                }
            }
        }
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
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
                    rule: payload.rule,
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
            .presentationDetents([.height(240)])
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
        .alert("Finish Session", isPresented: $showsFinishConfirmation) {
            Button("Finish") {
                finishWorkout()
                if template?.name == "Quick Start" {
                    renameDraft = ""
                    showsRenamePrompt = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will finish and save your session. Are you ready?")
        }
        .alert("Name this workout", isPresented: $showsRenamePrompt) {
            TextField("Workout name", text: $renameDraft)
            Button("Save") {
                let trimmed = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                if let template, !trimmed.isEmpty {
                    template.name = trimmed
                    try? modelContext.save()
                }
            }
            Button("Skip", role: .cancel) {}
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
                    .font(AppFont.productHeading)
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
        Button {
            showsAddExercise = true
        } label: {
            HStack(spacing: AppSpacing.xs) {
                AppIcon.add.image()
                Text("Add Exercise")
            }
            .font(AppFont.productAction)
            .foregroundStyle(AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
    }

    private var exerciseListSheet: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Exercises") {
                showLineup = false
            }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(sectionModels.enumerated()), id: \.element.id) { index, section in
                        let isLast = index == sectionModels.count - 1
                        let isCurrent = index == selectedExerciseIndex
                        let isDone = section.hasReachedPlannedSetGoal

                        SheetListRow(
                            title: section.exercise.displayName,
                            subtitle: exerciseListSubtitle(for: section),
                            titleStyle: isDone ? .muted : .primary,
                            showsBorder: !isLast
                        ) {
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExerciseIndex = index
                            showLineup = false
                        }
                    }
                }
                .background(AppColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                .padding(AppSpacing.md)
            }
        }
        .background(AppColor.sheetBackground.ignoresSafeArea())
    }

    private func exerciseListSubtitle(for section: WorkoutExerciseSectionModel) -> String? {
        guard let targetText = section.targetText else { return nil }
        let setCount = section.plannedSetCount
        return "\(setCount) x \(targetText)"
    }

    private var logsSheet: some View {
        VStack(spacing: AppSpacing.md) {
            SheetHeader(title: "Logs") {
                showLogs = false
            }

            if let currentSection {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<currentSection.plannedSetCount, id: \.self) { index in
                            let isLast = index == currentSection.plannedSetCount - 1
                            let entry = index < currentSection.entries.count ? currentSection.entries[index] : nil
                            let isCurrent = !currentSection.hasReachedPlannedSetGoal && index == currentSection.entries.count

                            SheetListRow(
                                title: "Set \(index + 1)",
                                subtitle: entry.map { logEntrySubtitle(for: $0, exercise: currentSection.exercise) },
                                titleStyle: entry != nil ? .muted : .primary,
                                showsBorder: !isLast
                            ) {
                                if let entry {
                                    if entry.metTarget {
                                        IconChip(icon: .checkmark)
                                    } else {
                                        IconChip(icon: .remove)
                                    }
                                } else if isCurrent {
                                    AppTag(text: "Current", style: .accent)
                                }
                            }
                        }
                    }
                    .background(AppColor.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                }
            }
        }
        .padding(AppSpacing.md)
    }

    private func logEntrySubtitle(for entry: SetEntry, exercise: Exercise) -> String {
        if exercise.isBodyweight {
            return "\(entry.reps) x BW"
        }
        return "\(entry.reps) x \(WorkoutTargetFormatter.weightDisplay(entry.weight))"
    }

    private func lastLoggedValues(for exerciseID: UUID) -> (weight: Double, reps: Int)? {
        let entries = currentEntries(for: exerciseID)
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
                state = entry.targetReps > 0 && !entry.metTarget ? .failed : .completed
                reps = entry.reps
                if section.exercise.isBodyweight {
                    weightText = "BW"
                } else if entry.weight > 0 {
                    weightText = WorkoutTargetFormatter.weightDisplay(entry.weight)
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

        if let targetText = section.targetText {
            return "Next: Set \(nextSetNumber) · \(targetText)"
        }

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
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) {
            selectedExerciseIndex += 1
        }
    }

    private func completeSuggestedSet(
        exercise: Exercise,
        rule: ProgressionRule?,
        target: ProgressionEngine.WeekTarget?,
        prefill: SetPrefill?
    ) {
        if let target {
            completeSet(
                exercise: exercise,
                rule: rule,
                weight: target.weightKg,
                reps: target.reps
            )
            return
        }

        // Auto-complete with values from previous set in this session
        if let lastValues = lastLoggedValues(for: exercise.id) {
            completeSet(
                exercise: exercise,
                rule: rule,
                weight: lastValues.weight,
                reps: lastValues.reps
            )
            return
        }

        // First set: open manual entry
        adjustResultPayload = AdjustResultPayload(
            exercise: exercise,
            rule: rule,
            prefill: prefill
        )
    }

    private func completeSet(
        exercise: Exercise,
        rule: ProgressionRule?,
        weight: Double,
        reps: Int,
        note: String = ""
    ) {
        let setIndex = currentEntries(for: exercise.id).count

        var targetWeight = 0.0
        var targetReps = 0
        if let rule, let cycle = activeCycle, session.weekNumber > 0 {
            let snapshot = rule.snapshot(weekCount: cycle.weekCount)
            let outcomes = rule.buildOutcomes(from: Array(sessions))
            if let target = ProgressionEngine.target(for: session.weekNumber, rule: snapshot, outcomes: outcomes) {
                targetWeight = target.weightKg
                targetReps = target.reps
            }
        }

        let hasTrustedTarget = targetReps > 0 && (exercise.isBodyweight || targetWeight > 0)
        let metTarget: Bool
        if hasTrustedTarget {
            let metWeight = exercise.isBodyweight || weight >= targetWeight
            metTarget = metWeight && reps >= targetReps
        } else {
            metTarget = false
        }

        let entry = SetEntry(
            sessionId: session.id,
            exerciseId: exercise.id,
            weight: weight,
            reps: reps,
            rpe: 0,
            rir: -1,
            targetWeight: targetWeight,
            targetReps: targetReps,
            metTarget: metTarget,
            isWarmup: false,
            isCompleted: true,
            setIndex: setIndex,
            note: note
        )
        entry.session = session
        modelContext.insert(entry)
        try? modelContext.save()

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let completedSetCount = setIndex + 1
        let plannedCount = plannedSetCount(for: exercise.id)

        showsReadyState = false

        if completedSetCount >= plannedCount {
            restTimer.stop()
        } else {
            startRestTimer(seconds: restDurationSeconds)
        }
    }

    private func finishWorkout() {
        restTimer.stop()
        session.isCompleted = true
        try? modelContext.save()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
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
    let rule: ProgressionRule?
    let weekTarget: ProgressionEngine.WeekTarget?
    let targetText: String?
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
    let rule: ProgressionRule?
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
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sheetHeader

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

                TextField("Optional note", text: $noteText)
                    .font(AppFont.body.font)
                    .appInputFieldStyle()

                AppPrimaryButton("Save", isEnabled: canSave) {
                    onSave(effectiveIsBodyweight ? 0 : parsedWeight, parsedReps, noteText)
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
            .padding(.top, AppSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            guard !seeded else { return }
            seeded = true
            guard let prefill else { return }
            if !isBodyweight {
                weightText = prefill.weight.weightString
            }
            repsText = "\(prefill.reps)"
        }
    }

    private var sheetHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(exerciseName)
                    .appFont(.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Log a different result for this set.")
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: AppSpacing.sm)

            AppHeaderIconButton(icon: .close) {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func manualInputField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        suffix: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                TextField("0", text: text)
                    .keyboardType(keyboardType)
                    .font(AppFont.numericDisplay)
                    .multilineTextAlignment(.center)

                if let suffix {
                    Text(suffix)
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .appInputFieldStyle(height: 64, horizontalPadding: AppSpacing.sm)
        }
    }
}

private struct SetCountPickerSheet: View {
    let exerciseName: String
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCount = 3

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text(exerciseName)
                .font(AppFont.productHeading)
                .foregroundStyle(AppColor.textPrimary)

            Text("How many sets?")
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textSecondary)

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
                    .buttonStyle(.plain)
                }
            }

            AppPrimaryButton("Start") {
                onSelect(selectedCount)
                dismiss()
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.lg)
    }
}

private struct AddExerciseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    let existingIds: Set<UUID>
    let onSelect: (Exercise) -> Void

    @State private var query = ""

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
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search or create new")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
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
    let weight: Double
    let reps: Int
}

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    func target(
        for weekNumber: Int,
        rule: ProgressionRule?,
        cycle: Cycle?,
        sessions: [WorkoutSession]
    ) -> ProgressionEngine.WeekTarget? {
        guard let rule, let cycle, weekNumber > 0 else { return nil }
        return ProgressionEngine.target(
            for: weekNumber,
            rule: rule.snapshot(weekCount: cycle.weekCount),
            outcomes: rule.buildOutcomes(from: sessions)
        )
    }

    func prefillSet(
        for exerciseID: UUID,
        currentSession: WorkoutSession,
        sessions: [WorkoutSession],
        rule: ProgressionRule?,
        cycle: Cycle?
    ) -> SetPrefill? {
        let currentEntries = currentSession.setEntries
            .filter { $0.exerciseId == exerciseID }
            .sorted { $0.setIndex < $1.setIndex }

        if let currentLast = currentEntries.last {
            return SetPrefill(weight: currentLast.weight, reps: currentLast.reps)
        }

        if let rule, let cycle, currentSession.weekNumber > 0 {
            if let target = ProgressionEngine.target(
                for: currentSession.weekNumber,
                rule: rule.snapshot(weekCount: cycle.weekCount),
                outcomes: rule.buildOutcomes(from: sessions)
            ) {
                return SetPrefill(weight: target.weightKg, reps: target.reps)
            }
        }

        guard let reference = latestSessionSet(
            for: exerciseID,
            currentSession: currentSession,
            sessions: sessions
        ) else {
            return nil
        }

        return SetPrefill(weight: reference.weight, reps: reference.reps)
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
        startActivity()
        startCountdownTask()
    }

    func pause() {
        guard isRunning, secondsRemaining > 0 else { return }
        task?.cancel()
        task = nil
        isRunning = false
        endDate = nil
        endActivity()
    }

    func resume() {
        guard !isRunning, secondsRemaining > 0 else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
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
        endActivity()
    }

    private func completeIfFinished() {
        secondsRemaining = 0
        isRunning = false
        totalDuration = 0
        endDate = nil
        completionCount += 1
        endActivity()
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
