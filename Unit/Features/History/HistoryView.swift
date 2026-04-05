//
//  HistoryView.swift
//  Unit
//
//  MVP history inside Program: list-first recent sessions with a quiet calendar browser.
//

import SwiftUI
import SwiftData

enum SessionHistoryMode: String, CaseIterable, Identifiable {
    case list = "List"
    case calendar = "Calendar"

    var id: Self { self }
}

enum SessionReviewState: Equatable {
    case completed
    case partial
    case skipped

    var title: String {
        switch self {
        case .completed: return "Completed"
        case .partial: return "Partial"
        case .skipped: return "Skipped"
        }
    }

    var markerColor: Color {
        switch self {
        case .completed: return AppColor.accent
        case .partial: return AppColor.warning
        case .skipped: return AppColor.error
        }
    }

    var tagStyle: AppTag.Style {
        switch self {
        case .completed:
            return .default
        case .partial:
            return .warning
        case .skipped:
            return .error
        }
    }
}

private enum CalendarDayStatus: Equatable {
    case empty
    case completed
    case partial
    case skipped
}

struct SessionSetSnapshot: Identifiable {
    let id: UUID
    let setIndex: Int
    let targetWeight: Double
    let targetReps: Int
    let actualWeight: Double
    let actualReps: Int
    let metTarget: Bool
    let note: String
}

struct SessionExerciseSnapshot: Identifiable {
    let id: UUID
    let name: String
    let isBodyweight: Bool
    let sets: [SessionSetSnapshot]

    /// Exercise summary, “3 × 15 × 27.5kg” style.
    var previewPerformanceText: String? {
        guard let representativeSet = sets.first else { return nil }
        return WorkoutTargetFormatter.actualText(
            weightKg: representativeSet.actualWeight,
            setCount: max(sets.count, 1),
            reps: representativeSet.actualReps,
            isBodyweight: isBodyweight
        )
    }
}

struct SessionSnapshot: Identifiable {
    let id: UUID
    let date: Date
    let templateName: String
    let weekNumber: Int
    let state: SessionReviewState
    let exercises: [SessionExerciseSnapshot]
    let overallFeeling: Int
    let contextNote: String?

    var completedExerciseCount: Int {
        exercises.count
    }

    var setCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    /// One line: first exercise · load × reps · +N more exercises.
    var compactExerciseHeadline: String? {
        guard let primaryExercise = exercises.first else { return nil }
        let headline = [primaryExercise.name, primaryExercise.previewPerformanceText]
            .compactMap { $0 }
            .joined(separator: " · ")
        let additionalExerciseCount = max(completedExerciseCount - 1, 0)
        if additionalExerciseCount > 0 {
            let suffix = "+\(additionalExerciseCount) more exercise\(additionalExerciseCount == 1 ? "" : "s")"
            return headline.isEmpty ? suffix : "\(headline) · \(suffix)"
        }
        return headline.isEmpty ? nil : headline
    }
}

struct SelectedSessionsPayload: Identifiable {
    let id = UUID()
    let date: Date
    let sessions: [SessionSnapshot]
}

private struct CalendarDayCellModel: Identifiable {
    let date: Date
    let dayNumber: Int
    let isToday: Bool
    let isSelected: Bool
    let sessionCount: Int
    let status: CalendarDayStatus
    let sessions: [SessionSnapshot]

    var id: Date { date }
    var hasSessions: Bool { !sessions.isEmpty }
}

struct RecentSessionsView: View {
    let showsCloseButton: Bool
    let initialMode: SessionHistoryMode

    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    @Environment(\.dismiss) private var dismiss

    @State private var mode: SessionHistoryMode
    @State private var displayMonth: Date = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate: Date?
    @State private var selectedPayload: SelectedSessionsPayload?

    private var historySessions: [WorkoutSession] {
        sessions.filter { session in
            session.isCompleted ||
            session.setEntries.contains(where: { $0.isCompleted }) ||
            (!session.isCompleted && session.setEntries.isEmpty && !Calendar.current.isDateInToday(session.date))
        }
    }

    private var templateNamesByID: [UUID: String] {
        Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0.displayName) })
    }

    private var exercisesByID: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
    }

    private var sessionSnapshots: [SessionSnapshot] {
        historySessions.compactMap(makeSnapshot(for:))
    }

    private var sessionsByDay: [Date: [SessionSnapshot]] {
        Dictionary(grouping: sessionSnapshots, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    private var selectedDaySessions: [SessionSnapshot] {
        guard let selectedDate else { return [] }
        return sessionsByDay[selectedDate] ?? []
    }

    var body: some View {
        AppScreen(
            showsNativeNavigationBar: true
        ) {
            if sessionSnapshots.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    modeToggle

                    if mode == .list {
                        listContent
                    } else {
                        calendarContent
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
        .toolbar(.hidden, for: .tabBar)
        .sheet(item: $selectedPayload) { payload in
            SessionSummarySheet(payload: payload)
                .presentationDetents([.medium, .large])
                .appBottomSheetChrome()
        }
        .onAppear {
            syncCalendarSelectionIfNeeded()
        }
        .onChange(of: displayMonth) { _, _ in
            syncCalendarSelectionIfNeeded()
        }
    }

    private var modeToggle: some View {
        Picker("History view", selection: $mode) {
            ForEach(SessionHistoryMode.allCases) { item in
                Text(item.rawValue).tag(item)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("No sessions yet")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Completed workouts will appear here so you can check the last session or browse by date.")
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private var sortedDays: [(date: Date, sessions: [SessionSnapshot])] {
        sessionsByDay
            .map { (date: $0.key, sessions: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(sortedDays, id: \.date) { day in
                Button {
                    selectedDate = day.date
                    selectedPayload = SelectedSessionsPayload(date: day.date, sessions: day.sessions)
                } label: {
                    DaySessionCard(date: day.date, sessions: day.sessions)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var calendarContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    CalendarMonthHeader(displayMonth: $displayMonth)

                    CalendarGrid(
                        displayMonth: displayMonth,
                        sessionsByDay: sessionsByDay,
                        selectedDate: selectedDate,
                        onSelect: { day in
                            guard day.hasSessions else { return }
                            selectedDate = day.date
                        }
                    )
                }
            }

            if let selectedDate, !selectedDaySessions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(selectedDaySessions) { snapshot in
                        Button {
                            selectedPayload = SelectedSessionsPayload(date: selectedDate, sessions: [snapshot])
                        } label: {
                            CalendarSessionCard(
                                snapshot: snapshot,
                                isToday: Calendar.current.isDateInToday(selectedDate)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func syncCalendarSelectionIfNeeded() {
        let calendar = Calendar.current

        if let selectedDate,
           calendar.isDate(selectedDate, equalTo: displayMonth, toGranularity: .month),
           sessionsByDay[selectedDate] != nil {
            return
        }

        let monthSessions = sessionsByDay.keys
            .filter { calendar.isDate($0, equalTo: displayMonth, toGranularity: .month) }
            .sorted()

        if let todayMatch = monthSessions.first(where: { calendar.isDateInToday($0) }) {
            selectedDate = todayMatch
        } else {
            selectedDate = monthSessions.last
        }
    }

    private func makeSnapshot(for session: WorkoutSession) -> SessionSnapshot? {
        makeHistorySessionSnapshot(
            for: session,
            templateNamesByID: templateNamesByID,
            exercisesByID: exercisesByID
        )
    }
}

func makeHistorySessionSnapshot(
    for session: WorkoutSession,
    templateNamesByID: [UUID: String],
    exercisesByID: [UUID: Exercise]
) -> SessionSnapshot? {
    let completedEntries = session.setEntries
        .filter { $0.isCompleted && !$0.isWarmup }
        .sorted { $0.setIndex < $1.setIndex }

    let isSkippedSession = !session.isCompleted && completedEntries.isEmpty

    guard !completedEntries.isEmpty || session.isCompleted || isSkippedSession else { return nil }

    let groupedEntries = Dictionary(grouping: completedEntries, by: \.exerciseId)
    let exerciseSnapshots = groupedEntries.compactMap { exerciseID, entries -> SessionExerciseSnapshot? in
        let exercise = exercisesByID[exerciseID]
        let name = exercise?.displayName ?? "Exercise"
        let sets = entries.map { entry in
            SessionSetSnapshot(
                id: entry.id,
                setIndex: entry.setIndex,
                targetWeight: entry.targetWeight,
                targetReps: entry.targetReps,
                actualWeight: entry.weight,
                actualReps: entry.reps,
                metTarget: entry.targetWeight > 0 || entry.targetReps > 0 ? entry.metTarget : true,
                note: entry.note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        .sorted { $0.setIndex < $1.setIndex }

        return SessionExerciseSnapshot(
            id: exerciseID,
            name: name,
            isBodyweight: exercise?.isBodyweight ?? false,
            sets: sets
        )
    }
    .sorted { $0.name < $1.name }

    let contextNote = completedEntries
        .map(\.note)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .first(where: { !$0.isEmpty })

    return SessionSnapshot(
        id: session.id,
        date: session.date,
        templateName: templateNamesByID[session.templateId] ?? "Workout",
        weekNumber: session.weekNumber,
        state: session.isCompleted ? .completed : (isSkippedSession ? .skipped : .partial),
        exercises: exerciseSnapshots,
        overallFeeling: session.overallFeeling,
        contextNote: contextNote
    )
}

extension RecentSessionsView {
    init(showsCloseButton: Bool = true, initialMode: SessionHistoryMode = .list) {
        self.showsCloseButton = showsCloseButton
        self.initialMode = initialMode
        _mode = State(initialValue: initialMode)
    }
}

struct HistoryView: View {
    let showsCloseButton: Bool
    let initialMode: SessionHistoryMode

    var body: some View {
        RecentSessionsView(showsCloseButton: showsCloseButton, initialMode: initialMode)
    }
}

struct RecentSessionListRow: View {
    let snapshot: SessionSnapshot

    var body: some View {
        sessionPreviewCardContent(snapshot: snapshot, showDisclosure: true)
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

private struct SessionStatusBadge: View {
    let state: SessionReviewState

    var body: some View {
        ZStack {
            Circle()
                .fill(state.markerColor.opacity(0.1))
                .frame(width: 24, height: 24)

            icon
                .foregroundStyle(state.markerColor)
        }
        .accessibilityLabel(state.title)
    }

    @ViewBuilder
    private var icon: some View {
        switch state {
        case .completed:
            AppIcon.checkmark.image(size: 12, weight: .bold)
        case .partial:
            AppIcon.remove.image(size: 12, weight: .bold)
        case .skipped:
            AppIcon.close.image(size: 10, weight: .bold)
        }
    }
}

private struct DaySessionCard: View {
    let date: Date
    let sessions: [SessionSnapshot]

    private var totalExercises: Int {
        sessions.reduce(0) { $0 + $1.completedExerciseCount }
    }

    private var overallState: SessionReviewState {
        if sessions.allSatisfy({ $0.state == .completed }) { return .completed }
        if sessions.contains(where: { $0.state == .skipped }) { return .skipped }
        return .partial
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                Text(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                    .font(AppFont.label.font)
                    .foregroundStyle(AppColor.textSecondary)

                Spacer(minLength: 0)

                SessionStatusBadge(state: overallState)
            }

            // Show template names (deduplicated)
            let templateNames = sessions.map(\.templateName)
            let uniqueNames = NSOrderedSet(array: templateNames).array as? [String] ?? templateNames
            Text(uniqueNames.joined(separator: " + "))
                .font(AppFont.title.font)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if totalExercises > 0 {
                Text("\(totalExercises) exercise\(totalExercises == 1 ? "" : "s")")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

// MARK: - Session preview card (calendar list + history rows)

extension SessionSnapshot {
    fileprivate var sessionStatusTint: Color {
        switch state {
        case .completed: return AppColor.success
        case .partial: return AppColor.warning
        case .skipped: return AppColor.error
        }
    }
}

@ViewBuilder
fileprivate func sessionPreviewCardContent(snapshot: SessionSnapshot, showDisclosure: Bool) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Text(snapshot.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.textSecondary)

            Spacer(minLength: 0)

            SessionStatusBadge(state: snapshot.state)
        }

        Text(snapshot.templateName)
            .font(AppFont.title.font)
            .foregroundStyle(AppColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)

        if let compactExerciseHeadline = snapshot.compactExerciseHeadline {
            Text(compactExerciseHeadline)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct CalendarMonthHeader: View {
    @Binding var displayMonth: Date

    private var monthTitle: String {
        displayMonth.formatted(.dateTime.month(.wide).year())
    }

    private var canGoForward: Bool {
        displayMonth < Calendar.current.startOfMonth(for: Date())
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Text(monthTitle)
                .appFont(.largeTitle)
                .foregroundStyle(AppColor.textPrimary)

            Spacer(minLength: 0)

            HStack(spacing: AppSpacing.xs) {
                monthNavChevron(icon: .back, accessibilityLabel: "Previous month") {
                    shiftMonth(by: -1)
                }

                monthNavChevron(icon: .forward, accessibilityLabel: "Next month", isEnabled: canGoForward) {
                    shiftMonth(by: 1)
                }
            }
        }
    }

    private func monthNavChevron(
        icon: AppIcon,
        accessibilityLabel: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            icon
                .image(size: 17, weight: .semibold)
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.45))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }

    private func shiftMonth(by value: Int) {
        guard let next = Calendar.current.date(byAdding: .month, value: value, to: displayMonth) else { return }
        displayMonth = next
    }
}

private struct CalendarGrid: View {
    let displayMonth: Date
    let sessionsByDay: [Date: [SessionSnapshot]]
    let selectedDate: Date?
    let onSelect: (CalendarDayCellModel) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.smd), count: 7)
    private let weekdayHeaders = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    private var dayCells: [CalendarDayCellModel?] {
        let calendar = Calendar.current
        let monthStart = calendar.startOfMonth(for: displayMonth)
        let today = calendar.startOfDay(for: Date())

        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }

        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingCount = (weekday + 5) % 7
        var result: [CalendarDayCellModel?] = Array(repeating: nil, count: leadingCount)

        for offset in 0..<dayRange.count {
            guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
            let dayNumber = offset + 1
            let daySessions = sessionsByDay[date] ?? []
            let status: CalendarDayStatus
            if daySessions.isEmpty {
                status = .empty
            } else if daySessions.contains(where: { $0.state == .skipped }) {
                status = .skipped
            } else if daySessions.contains(where: { $0.state == .partial }) {
                status = .partial
            } else {
                status = .completed
            }

            result.append(
                CalendarDayCellModel(
                    date: date,
                    dayNumber: dayNumber,
                    isToday: date == today,
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                    sessionCount: daySessions.count,
                    status: status,
                    sessions: daySessions.sorted { $0.date > $1.date }
                )
            )
        }

        return result
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.smd) {
                ForEach(weekdayHeaders, id: \.self) { header in
                    Text(header)
                        .font(AppFont.smallLabel)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.smd) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    if let cell {
                        CalendarDayCell(model: cell) {
                            onSelect(cell)
                        }
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
        }
    }
}

private struct CalendarDayCell: View {
    let model: CalendarDayCellModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(model.dayNumber)")
                .font(AppFont.body.font)
                .foregroundStyle(numberColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(outlineColor, lineWidth: outlineLineWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        }
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .disabled(!model.hasSessions)
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundColor: Color {
        if model.isSelected {
            return AppColor.accent
        }
        if model.isToday {
            return AppColor.controlBackground
        }
        switch model.status {
        case .completed:
            return AppColor.success.opacity(0.18)
        case .partial:
            return AppColor.warning.opacity(0.22)
        case .skipped:
            return AppColor.error.opacity(0.18)
        case .empty:
            return .clear
        }
    }

    private var outlineColor: Color {
        if model.isSelected {
            return AppColor.accent
        }
        if model.isToday {
            return AppColor.textPrimary.opacity(0.34)
        }
        return model.hasSessions ? AppColor.border : .clear
    }

    private var outlineLineWidth: CGFloat {
        (model.isSelected || model.isToday || model.hasSessions) ? 1 : 0
    }

    private var numberColor: Color {
        if model.isSelected {
            return AppColor.accentForeground
        }
        if model.isToday {
            return AppColor.textPrimary
        }
        switch model.status {
        case .completed:
            return AppColor.success
        case .partial:
            return AppColor.warning
        case .skipped:
            return AppColor.error
        case .empty:
            return AppColor.textSecondary
        }
    }

    private var accessibilityLabel: String {
        let dateLabel = model.date.formatted(date: .abbreviated, time: .omitted)
        let stateLabel: String
        switch model.status {
        case .empty:
            stateLabel = "no session"
        case .completed:
            stateLabel = "completed session"
        case .partial:
            stateLabel = "partial session"
        case .skipped:
            stateLabel = "skipped session"
        }
        return "\(dateLabel), \(stateLabel)"
    }
}

private struct CalendarSessionCard: View {
    let snapshot: SessionSnapshot
    let isToday: Bool

    var body: some View {
        sessionPreviewCardContent(snapshot: snapshot, showDisclosure: false)
            .padding(isToday ? AppSpacing.lg : AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

struct SessionSummarySheet: View {
    let payload: SelectedSessionsPayload

    @Environment(\.dismiss) private var dismiss

    private var headerTitle: String {
        let count = payload.sessions.count
        return "\(count) session\(count == 1 ? "" : "s")"
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: headerTitle) {
                dismiss()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ForEach(payload.sessions) { snapshot in
                        SessionSummaryCard(snapshot: snapshot)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .background(AppColor.background.ignoresSafeArea())
    }
}

private struct SessionSummaryCard: View {
    let snapshot: SessionSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sessionPreviewCardContent(snapshot: snapshot, showDisclosure: false)

            if snapshot.overallFeeling > 0 || snapshot.contextNote != nil {
                HStack(spacing: AppSpacing.xs) {
                    if snapshot.overallFeeling > 0 {
                        AppTag(text: "Felt \(snapshot.overallFeeling)/5", style: .muted)
                    }
                    if let contextNote = snapshot.contextNote {
                        AppTag(text: contextNote, style: .muted)
                    }
                }
            }

            AppDividedList(snapshot.exercises) { exercise in
                SessionExerciseSummary(exercise: exercise)
                    .padding(.vertical, AppSpacing.smd)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

struct SessionExerciseSummary: View {
    let exercise: SessionExerciseSnapshot

    /// Uniform size for every “Set N” label (same face/size so numbering looks identical).
    private static let setIndexFont = AppFont.caption.font
    /// Smaller than previous `AppFont.label` (17) while staying legible.
    private static let performanceFont = AppFont.compactLabel
    private static let secondaryMetaFont = AppFont.smallLabel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(exercise.name)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)

            ForEach(exercise.sets) { set in
                let hasTarget = set.targetWeight > 0 || set.targetReps > 0
                let isGood = !hasTarget || set.metTarget

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(setOrdinalLabel(for: set))
                                .font(Self.setIndexFont)
                                .foregroundStyle(AppColor.textSecondary)

                            if !isGood, hasTarget {
                                Text("Target \(targetText(for: set))")
                                    .font(Self.setIndexFont)
                                    .foregroundStyle(AppColor.textSecondary)

                                Text("Met \(actualText(for: set))")
                                    .font(Self.setIndexFont)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                        .frame(minWidth: 76, alignment: .leading)

                        Spacer(minLength: AppSpacing.sm)

                        if hasTarget, !isGood {
                            Text("Fail")
                                .font(Self.performanceFont)
                                .foregroundStyle(AppColor.warning)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                                Text(actualText(for: set))
                                    .font(Self.performanceFont)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .multilineTextAlignment(.trailing)
                                    .monospacedDigit()

                                if hasTarget {
                                    Text("Good")
                                        .font(Self.secondaryMetaFont)
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                            .frame(minWidth: 120, alignment: .trailing)
                        }
                    }

                    if !set.note.isEmpty {
                        Text(set.note)
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
        }
    }

    private func setOrdinalLabel(for set: SessionSetSnapshot) -> String {
        let n = set.setIndex + 1
        return "Set \(n)"
    }

    private func targetText(for set: SessionSetSnapshot) -> String {
        let hasTarget = set.targetWeight > 0 || set.targetReps > 0
        guard hasTarget else { return "No target" }
        return formatLoad(weight: set.targetWeight, reps: set.targetReps)
    }

    private func actualText(for set: SessionSetSnapshot) -> String {
        formatLoad(weight: set.actualWeight, reps: set.actualReps)
    }

    private func formatLoad(weight: Double, reps: Int) -> String {
        WorkoutTargetFormatter.actualText(
            weightKg: weight,
            setCount: 1,
            reps: reps,
            isBodyweight: exercise.isBodyweight
        )
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    NavigationStack {
        RecentSessionsView()
            .modelContainer(PreviewSampleData.makePreviewContainer())
    }
}
