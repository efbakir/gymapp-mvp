//
//  CalendarTabView.swift
//  Unit
//
//  Tab root: month calendar + inline day detail cards.
//

import SwiftData
import SwiftUI

struct CalendarTabView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    @AppStorage(ActiveSplitStore.defaultsKey) private var activeSplitIdString: String = ""

    @State private var displayMonth = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate: Date? = Calendar.current.startOfDay(for: Date())
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var templateNamesByID: [UUID: String] {
        Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0.name) })
    }

    private var exercisesByID: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
    }

    /// Routine template IDs from the primary split (same scope as Today week overview).
    private var routineTemplateIDs: [UUID] {
        ActiveSplitStore.resolve(from: splits)?.orderedTemplateIds ?? []
    }

    private var sessionSnapshots: [SessionSnapshot] {
        let qualifying = sessions.filter { session in
            session.isCompleted || session.setEntries.contains(where: { $0.isCompleted })
        }

        return qualifying.compactMap {
            makeHistorySessionSnapshot(
                for: $0,
                templateNamesByID: templateNamesByID,
                exercisesByID: exercisesByID
            )
        }
        .sorted { $0.date < $1.date }
    }

    private var monthSummaries: [CalendarDaySummary] {
        let monthStart = Calendar.current.startOfMonth(for: displayMonth)
        let grouped = Dictionary(grouping: sessionSnapshots) { snapshot in
            Calendar.current.startOfDay(for: snapshot.date)
        }

        return grouped
            .compactMap { date, snapshots in
                guard Calendar.current.isDate(date, equalTo: monthStart, toGranularity: .month) else {
                    return nil
                }

                return CalendarDaySummary(
                    date: date,
                    sessions: snapshots.sorted { $0.date > $1.date }
                )
            }
            .sorted { $0.date < $1.date }
    }

    private var monthSessionCount: Int {
        sessionSnapshots.filter {
            Calendar.current.isDate($0.date, equalTo: displayMonth, toGranularity: .month)
        }.count
    }

    private var summariesByDate: [Date: CalendarDaySummary] {
        Dictionary(uniqueKeysWithValues: monthSummaries.map { ($0.date, $0) })
    }

    /// Resolves the base state of a given day from session + routine data.
    private func dayState(for date: Date) -> CalendarDayState {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())

        if day > today {
            return .future
        }

        let hasLogged = summariesByDate[day]?.sessions.isEmpty == false

        if calendar.isDate(day, inSameDayAs: today) {
            return hasLogged ? .completed : .today
        }

        if hasLogged {
            return .completed
        }

        let isMissed = TrainingWeekProgressBuilder.isMissedTrainingDay(
            date: day,
            routineTemplateIDs: routineTemplateIDs,
            sessions: sessions
        )
        return isMissed ? .missed : .default
    }

    /// Returns the assigned workout name for a past missed date, if resolvable.
    private func assignedWorkoutName(on date: Date) -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        guard let split = ActiveSplitStore.resolve(from: splits) else { return "Assigned workout" }

        let templatesByID = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        let routineTemplates = split.orderedTemplateIds.compactMap { templatesByID[$0] }

        if let match = routineTemplates.first(where: { $0.scheduledWeekday == weekday }) {
            return match.displayName
        }
        return "Assigned workout"
    }

    private func handleCalendarDayTap(_ date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        let state = dayState(for: day)
        guard state == .completed || state == .missed || state == .today else { return }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            if let selectedDate, Calendar.current.isDate(selectedDate, inSameDayAs: day) {
                self.selectedDate = nil
            } else {
                self.selectedDate = day
            }
        }
    }

    @ViewBuilder
    private var detailSection: some View {
        if let selectedDate {
            let state = dayState(for: selectedDate)
            switch state {
            case .completed:
                if let summary = summariesByDate[Calendar.current.startOfDay(for: selectedDate)] {
                    CalendarDaySummaryCard(summary: summary)
                }
            case .missed:
                MissedDayCard(
                    date: selectedDate,
                    workoutName: assignedWorkoutName(on: selectedDate)
                )
            case .today:
                TodayDayCard(
                    date: selectedDate,
                    workoutName: assignedWorkoutName(on: selectedDate)
                )
            default:
                EmptyView()
            }
        }
    }

    var body: some View {
        NavigationStack {
            AppScreen(title: "Calendar", navigationBarTitleDisplayMode: .large) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    CalendarMonthCard(
                        displayMonth: $displayMonth,
                        selectedDate: $selectedDate,
                        sessionCount: monthSessionCount,
                        summariesByDate: summariesByDate,
                        dayStateProvider: { dayState(for: $0) },
                        onSelectDay: { date in
                            handleCalendarDayTap(date)
                        }
                    )

                    detailSection
                }
            }
            .tint(AppColor.systemTint)
        }
    }
}

private struct CalendarMonthCard: View {
    @Binding var displayMonth: Date
    @Binding var selectedDate: Date?
    let sessionCount: Int
    let summariesByDate: [Date: CalendarDaySummary]
    let dayStateProvider: (Date) -> CalendarDayState
    let onSelectDay: (Date) -> Void

    private var canGoForward: Bool {
        displayMonth < Calendar.current.startOfMonth(for: Date())
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(displayMonth.formatted(.dateTime.month(.wide).year()))
                            .appFont(.largeTitle)
                            .foregroundStyle(AppColor.textPrimary)

                        Text("\(sessionCount) session\(sessionCount == 1 ? "" : "s") logged")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: AppSpacing.xs) {
                        monthNavButton(
                            icon: .back,
                            accessibilityLabel: "Previous month",
                            isEnabled: true
                        ) {
                            shiftMonth(by: -1)
                        }

                        monthNavButton(
                            icon: .forward,
                            accessibilityLabel: "Next month",
                            isEnabled: canGoForward
                        ) {
                            shiftMonth(by: 1)
                        }
                    }
                    .padding(.top, AppSpacing.xs / 2)
                }

                CalendarMonthGrid(
                    displayMonth: displayMonth,
                    selectedDate: selectedDate,
                    dayStateProvider: dayStateProvider,
                    onSelectDay: onSelectDay
                )
            }
        }
    }

    private func monthNavButton(
        icon: AppIcon,
        accessibilityLabel: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            AppIconCircle(surface: .control) {
                icon
                    .image(size: AppIconCircleSize.icon, weight: AppIconCircleSize.weight)
                    .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.45))
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }

    private func shiftMonth(by value: Int) {
        let calendar = Calendar.current
        guard let next = calendar.date(byAdding: .month, value: value, to: displayMonth) else { return }
        displayMonth = next
        let today = calendar.startOfDay(for: Date())
        if calendar.isDate(next, equalTo: today, toGranularity: .month) {
            selectedDate = today
        } else {
            selectedDate = nil
        }
    }
}

private struct CalendarMonthGrid: View {
    let displayMonth: Date
    let selectedDate: Date?
    let dayStateProvider: (Date) -> CalendarDayState
    let onSelectDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 7)
    private let weekdayHeaders = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    private var dayCells: [CalendarGridCellModel?] {
        let calendar = Calendar.current
        let monthStart = calendar.startOfMonth(for: displayMonth)

        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }

        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingCount = (weekday + 5) % 7
        var result: [CalendarGridCellModel?] = Array(repeating: nil, count: leadingCount)

        for offset in 0..<dayRange.count {
            guard let date = calendar.date(byAdding: .day, value: offset, to: monthStart) else { continue }
            let dayNumber = offset + 1

            result.append(
                CalendarGridCellModel(
                    date: date,
                    dayNumber: dayNumber,
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                    isToday: calendar.isDateInToday(date),
                    state: dayStateProvider(date)
                )
            )
        }

        return result
    }

    var body: some View {
        VStack(spacing: AppSpacing.smd) {
            HStack(spacing: AppSpacing.sm) {
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
                        CalendarGridDayCell(model: cell) {
                            onSelectDay(cell.date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
}

private struct CalendarGridDayCell: View {
    let model: CalendarGridCellModel
    let action: () -> Void

    private var isInteractive: Bool {
        model.state == .completed || model.state == .missed || model.state == .today
    }

    var body: some View {
        Group {
            if isInteractive {
                Button(action: action) {
                    cellContent
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                cellContent
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isInteractive ? [.isButton] : [])
    }

    private var cellContent: some View {
        Text("\(model.dayNumber)")
            .font(AppFont.caption.font)
            .fontWeight(model.isToday ? .semibold : .medium)
            .foregroundStyle(numberColor)
            .frame(minWidth: 36, minHeight: 38)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .strokeBorder(ringColor, style: ringStyle)
            )
    }

    private var backgroundColor: Color {
        switch model.state {
        case .completed:
            return AppColor.successSoft
        case .missed:
            return AppColor.warningSoft
        case .today:
            return AppColor.controlBackground
        case .default, .future:
            return .clear
        }
    }

    private var numberColor: Color {
        switch model.state {
        case .completed:
            return AppColor.successOnSoft
        case .missed:
            return AppColor.warningOnSoft
        case .today:
            return AppColor.textPrimary
        case .default:
            return AppColor.textSecondary
        case .future:
            return AppColor.textSecondary.opacity(0.55)
        }
    }

    private var ringColor: Color {
        model.isSelected ? AppColor.accent : .clear
    }

    private var ringStyle: StrokeStyle {
        model.isSelected ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 0)
    }

    private var accessibilityLabel: String {
        let dateLabel = model.date.formatted(date: .abbreviated, time: .omitted)
        let stateLabel: String
        switch model.state {
        case .default:
            stateLabel = "no session"
        case .completed:
            stateLabel = "logged session"
        case .missed:
            stateLabel = "missed"
        case .today:
            stateLabel = "today"
        case .future:
            stateLabel = "upcoming"
        }
        let selected = model.isSelected ? ", selected" : ""
        return "\(dateLabel), \(stateLabel)\(selected)"
    }
}

private struct CalendarDaySummaryCard: View {
    let summary: CalendarDaySummary

    var body: some View {
        AppSessionHighlightCard(
            eyebrow: summary.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()),
            title: summary.primaryTitle,
            caption: summary.subtitle
        ) {
            AppTag(text: "Completed", style: .success, layout: .compactCapsule)
        }
    }
}

private struct MissedDayCard: View {
    let date: Date
    let workoutName: String

    var body: some View {
        AppSessionHighlightCard(
            eyebrow: date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()),
            title: workoutName,
            caption: nil
        ) {
            AppTag(text: "Missed", style: .warning, layout: .compactCapsule)
        }
    }
}

private struct TodayDayCard: View {
    let date: Date
    let workoutName: String

    var body: some View {
        AppSessionHighlightCard(
            eyebrow: date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()),
            title: workoutName,
            caption: nil
        ) {
            AppTag(text: "Today", style: .default, layout: .compactCapsule)
        }
    }
}

private struct CalendarDaySummary: Identifiable {
    let date: Date
    let sessions: [SessionSnapshot]

    var id: Date { date }

    var primaryTitle: String {
        sessions.first?.templateName ?? "Workout"
    }

    var subtitle: String {
        sessions.first?.compactExerciseHeadline ?? "No details available"
    }
}

enum CalendarDayState: Equatable {
    case `default`
    case completed
    case missed
    case today
    case future
}

private struct CalendarGridCellModel: Identifiable {
    let date: Date
    let dayNumber: Int
    let isSelected: Bool
    let isToday: Bool
    let state: CalendarDayState

    var id: Date { date }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    CalendarTabView()
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
