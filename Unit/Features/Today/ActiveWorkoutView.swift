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
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query private var progressionRules: [ProgressionRule]
    @Query private var cycles: [Cycle]

    @State private var viewModel = ActiveWorkoutViewModel()
    @State private var restTimer = RestTimerManager()
    @State private var restDurationSeconds = 180
    @State private var showLineup = false
    @State private var showLogs = false
    @State private var adjustResultPayload: AdjustResultPayload?
    @State private var selectedExerciseIndex = 0
    @State private var showsReadyState = false

    private var template: DayTemplate? {
        templates.first(where: { $0.id == session.templateId })
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
            finishWorkout()
        }
    }

    private var nextExerciseBarState: SessionStateBar.State? {
        guard let nextSection, !isWorkoutComplete else { return nil }
        return .nextExercise(subtitle: nextSection.exercise.displayName)
    }

    private var currentMetricValue: String {
        guard let currentSection else { return "Target unavailable" }

        if let target = currentSection.weekTarget {
            if currentSection.exercise.isBodyweight {
                return "\(target.reps) x Bodyweight"
            }

            if target.weightKg > 0 {
                return "\(target.reps) x \(WorkoutTargetFormatter.weightDisplay(target.weightKg))"
            }
        }

        return currentSection.targetText ?? "Target unavailable"
    }

    private var currentMetricSupportingText: String? {
        guard let currentSection else { return nil }

        if currentSection.targetText == nil {
            return "Use Edit to log a result."
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
        return currentSection.targetText == nil ? .disabled : .active
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
            title: nil,
            primaryButton: primaryButton,
            customHeader: ProductTopBar(
                title: template?.name ?? "Workout",
                size: .md,
                trailingActions: [
                    .text("List") {
                        showLineup = true
                    },
                    .text("Cancel") {
                        cancelWorkout()
                    }
                ]
            ).eraseToAnyView(),
            navigationBarTitleDisplayMode: .inline
        ) {
            if let currentSection {
                VStack(spacing: AppSpacing.lg) {
                    WorkoutCommandCard(
                        progressSteps: progressSteps(for: currentSection),
                        exerciseName: currentSection.exercise.displayName,
                        metricValue: currentMetricValue,
                        metricSupportingText: currentMetricSupportingText,
                        state: workoutCommandCardState,
                        primaryLabel: "Done",
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
                }
                .frame(maxWidth: .infinity, alignment: .top)
            } else {
                emptyWorkoutState
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
    }

    private var emptyWorkoutState: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("No exercises in this day")
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)

            Text("Add exercises in Program before starting this workout.")
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textSecondary)
        }
        .appCardStyle()
    }

    private var exerciseListSheet: some View {
        VStack(spacing: AppSpacing.md) {
            SheetHeader(title: "Exercise List") {
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
                                IconChip(icon: .checkmark)
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
            }
        }
        .padding(AppSpacing.md)
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

    private func currentEntries(for exerciseID: UUID) -> [SetEntry] {
        session.setEntries
            .filter { $0.exerciseId == exerciseID }
            .sorted { $0.setIndex < $1.setIndex }
    }

    private func progressSteps(for section: WorkoutExerciseSectionModel) -> [SetProgressIndicator.Step] {
        (0..<section.plannedSetCount).map { index in
            let state: SetProgressIndicator.Step.State

            if index < section.entries.count {
                let entry = section.entries[index]
                state = entry.targetReps > 0 && !entry.metTarget ? .failed : .completed
            } else if !section.hasReachedPlannedSetGoal && index == section.entries.count {
                state = .current
            } else {
                state = .upcoming
            }

            return SetProgressIndicator.Step(
                id: index,
                label: "\(index + 1)",
                state: state
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
        return { adjustRestTimer(by: -15) }
    }

    private var increaseRestTimerAction: (() -> Void)? {
        guard currentSection != nil, !isWorkoutComplete else { return nil }
        return { adjustRestTimer(by: 15) }
    }

    private var toggleRestTimerAction: (() -> Void)? {
        guard currentSection != nil, !isWorkoutComplete else { return nil }
        return { toggleRestTimer() }
    }

    private var goToNextExerciseAction: (() -> Void)? {
        guard nextSection != nil else { return nil }
        return { goToNextExercise() }
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
        withAnimation(.easeInOut(duration: 0.18)) {
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

        if session.overallFeeling == 0 {
            UserDefaults.standard.set(session.id.uuidString, forKey: "pendingFeelingSessionId")
        }
    }

    private func cancelWorkout() {
        restTimer.stop()
        modelContext.delete(session)
        try? modelContext.save()
    }

    private func plannedSetCount(for exerciseID: UUID) -> Int {
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

    private var canSave: Bool {
        if isBodyweight {
            return parsedReps > 0
        }
        return parsedWeight > 0 && parsedReps > 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sheetHeader

                if !isBodyweight {
                    manualInputField(title: "WEIGHT (kg)", text: $weightText, keyboardType: .decimalPad)
                }

                manualInputField(title: "REPS", text: $repsText, keyboardType: .numberPad)

                TextField("Optional note", text: $noteText)
                    .font(AppFont.body.font)
                    .appInputFieldStyle()

                AppPrimaryButton("Save", isEnabled: canSave) {
                    onSave(isBodyweight ? 0 : parsedWeight, parsedReps, noteText)
                    dismiss()
                }
            }
            .padding(AppSpacing.md)
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
                    .font(AppFont.largeTitle.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Log a different result for this set.")
                    .font(AppFont.caption.font)
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
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)

            TextField("0", text: text)
                .keyboardType(keyboardType)
                .font(AppFont.numericDisplay)
                .multilineTextAlignment(.center)
                .appInputFieldStyle(height: 64, horizontalPadding: AppSpacing.sm)
        }
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

    var label: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func start(totalSeconds: Int) {
        stop()
        totalDuration = totalSeconds
        secondsRemaining = totalSeconds
        isRunning = true
        startActivity(secondsRemaining: totalSeconds)
        startCountdownTask()
    }

    func pause() {
        guard secondsRemaining > 0 else { return }
        task?.cancel()
        task = nil
        isRunning = false
        endActivity()
    }

    func resume() {
        guard secondsRemaining > 0 else { return }
        guard !isRunning else { return }
        isRunning = true
        startActivity(secondsRemaining: secondsRemaining)
        startCountdownTask()
    }

    func adjust(by delta: Int, minimumSeconds: Int = 30) {
        let baseRemaining = secondsRemaining > 0 ? secondsRemaining : totalDuration
        let updatedRemaining = max(minimumSeconds, baseRemaining + delta)
        let updatedTotal = max(minimumSeconds, totalDuration + delta)

        secondsRemaining = updatedRemaining
        totalDuration = updatedTotal

        guard isRunning else { return }

        updateActivity(secondsRemaining: updatedRemaining)
    }

    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
        secondsRemaining = 0
        totalDuration = 0
        endActivity()
    }

    private func completeIfFinished() {
        secondsRemaining = 0
        isRunning = false
        totalDuration = 0
        completionCount += 1
        endActivity()
    }

    private func startCountdownTask() {
        task?.cancel()
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let manager = self else { return }
                guard manager.secondsRemaining > 0 else {
                    manager.completeIfFinished()
                    return
                }

                try? await Task.sleep(for: .seconds(1))

                if Task.isCancelled { return }
                manager.secondsRemaining -= 1
            }
        }
    }

    private func startActivity(secondsRemaining: Int) {
        let endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
        let attributes = RestTimerAttributes()
        let state = RestTimerAttributes.ContentState(endDate: endDate)
        let content = ActivityContent(state: state, staleDate: endDate.addingTimeInterval(60))
        activity = try? Activity<RestTimerAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
    }

    private func updateActivity(secondsRemaining: Int) {
        let endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
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
