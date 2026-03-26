//
//  CalendarTabView.swift
//  Unit
//
//  Tab root: month calendar + inline day detail cards.
//

import SwiftData
import SwiftUI

struct CalendarTabView: View {
    @Environment(\.appTabSelection) private var appTabSelection

    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @Query(sort: \Exercise.displayName) private var exercises: [Exercise]

    @State private var displayMonth = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate: Date?
    @State private var selectedPayload: SelectedSessionsPayload?

    private var templateNamesByID: [UUID: String] {
        Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0.name) })
    }

    private var exercisesByID: [UUID: Exercise] {
        Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
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

    private var visibleSummaries: [CalendarDaySummary] {
        guard let selectedDate else { return monthSummaries }
        return monthSummaries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var monthSessionCount: Int {
        sessionSnapshots.filter {
            Calendar.current.isDate($0.date, equalTo: displayMonth, toGranularity: .month)
        }.count
    }

    private func handleCalendarDayTap(_ date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if Calendar.current.isDateInToday(day) {
            appTabSelection(.today)
            return
        }
        if let summary = monthSummaries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }),
           !summary.sessions.isEmpty {
            selectedDate = day
            selectedPayload = SelectedSessionsPayload(date: day, sessions: summary.sessions)
            return
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            if let selectedDate, Calendar.current.isDate(selectedDate, inSameDayAs: day) {
                self.selectedDate = nil
            } else {
                self.selectedDate = day
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
                        summaries: monthSummaries,
                        onSelectDay: { date in
                            handleCalendarDayTap(date)
                        }
                    )

                    if visibleSummaries.isEmpty {
                        CalendarEmptyDetailsCard(date: selectedDate)
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            ForEach(visibleSummaries) { summary in
                                Button {
                                    if Calendar.current.isDateInToday(summary.date) {
                                        appTabSelection(.today)
                                    } else {
                                        selectedPayload = SelectedSessionsPayload(
                                            date: summary.date,
                                            sessions: summary.sessions
                                        )
                                    }
                                } label: {
                                    CalendarDaySummaryCard(
                                        summary: summary,
                                        isHighlighted: selectedDate.map {
                                            Calendar.current.isDate($0, inSameDayAs: summary.date)
                                        } ?? false
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedPayload) { payload in
                SessionSummarySheet(payload: payload)
                    .presentationDetents([.medium, .large])
                    .appBottomSheetChrome()
            }
            .tint(AppColor.accent)
        }
    }
}

private struct CalendarMonthCard: View {
    @Binding var displayMonth: Date
    @Binding var selectedDate: Date?
    let sessionCount: Int
    let summaries: [CalendarDaySummary]
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
                            .font(AppFont.largeTitle.font)
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
                    summariesByDate: Dictionary(uniqueKeysWithValues: summaries.map { ($0.date, $0) }),
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
        selectedDate = nil
    }
}

private struct CalendarMonthGrid: View {
    let displayMonth: Date
    let selectedDate: Date?
    let summariesByDate: [Date: CalendarDaySummary]
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
            let summary = summariesByDate[date]

            result.append(
                CalendarGridCellModel(
                    date: date,
                    dayNumber: dayNumber,
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                    status: CalendarGridCellStatus(date: date, summary: summary)
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
                            .frame(height: 32)
                    }
                }
            }
        }
    }
}

private struct CalendarGridDayCell: View {
    let model: CalendarGridCellModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(model.dayNumber)")
                .font(AppFont.caption.font)
                .foregroundStyle(numberColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(borderColor, lineWidth: borderLineWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch model.status {
        case .today:
            return model.isSelected ? AppColor.accent : AppColor.controlBackground
        case .completed:
            return AppColor.success.opacity(0.18)
        case .failed:
            return AppColor.error.opacity(0.18)
        case .empty:
            return .clear
        }
    }

    private var numberColor: Color {
        switch model.status {
        case .today:
            return model.isSelected ? AppColor.accentForeground : AppColor.textPrimary
        case .completed:
            return AppColor.success
        case .failed:
            return AppColor.error
        case .empty:
            return AppColor.textSecondary
        }
    }

    private var borderColor: Color {
        if model.status == .today, !model.isSelected {
            return AppColor.textPrimary.opacity(0.34)
        }
        if model.isSelected, model.status == .empty {
            return AppColor.textPrimary.opacity(0.35)
        }
        return .clear
    }

    private var borderLineWidth: CGFloat {
        if model.status == .today, !model.isSelected {
            return 1
        }
        return model.isSelected && model.status == .empty ? 1 : 0
    }
}

private struct CalendarDaySummaryCard: View {
    let summary: CalendarDaySummary
    let isHighlighted: Bool

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.smd) {
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    Text(summary.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(AppFont.label.font)
                        .foregroundStyle(AppColor.textSecondary)

                    Spacer(minLength: 0)

                    AppTag(text: summary.status.label, style: summary.status.tagStyle)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(summary.primaryTitle)
                        .font(AppFont.title.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(summary.subtitle)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(borderColor, lineWidth: borderLineWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private var borderColor: Color {
        AppColor.border.opacity(0.6)
    }

    private var borderLineWidth: CGFloat {
        1
    }
}

private struct CalendarEmptyDetailsCard: View {
    let date: Date?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                if let date {
                    Text(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)

                    Text("No logged session for this day.")
                        .font(AppFont.label.font)
                        .foregroundStyle(AppColor.textPrimary)
                } else {
                    Text("Select a day to view its details.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
}

private struct CalendarDaySummary: Identifiable {
    let date: Date
    let sessions: [SessionSnapshot]

    var id: Date { date }

    var status: CalendarSummaryStatus {
        if Calendar.current.isDateInToday(date) {
            if sessions.isEmpty { return .today }
            if sessions.contains(where: { $0.state == .partial || $0.hasFailure }) {
                return .failed
            }
            return .completed
        }
        if sessions.contains(where: { $0.state == .partial || $0.hasFailure }) {
            return .failed
        }
        return .completed
    }

    var primaryTitle: String {
        sessions.first?.templateName ?? "Workout"
    }

    var subtitle: String {
        sessions.first?.compactExerciseHeadline ?? "No details available"
    }
}

private enum CalendarSummaryStatus: Equatable {
    case completed
    case failed
    case today

    var label: String {
        switch self {
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .today:
            return "Today"
        }
    }

    var tagStyle: AppTag.Style {
        switch self {
        case .completed:
            return .success
        case .failed:
            return .error
        case .today:
            return .accent
        }
    }
}

private enum CalendarGridCellStatus: Equatable {
    case empty
    case completed
    case failed
    case today

    init(date: Date, summary: CalendarDaySummary?) {
        if Calendar.current.isDateInToday(date) {
            self = .today
        } else if let summary {
            switch summary.status {
            case .completed:
                self = .completed
            case .failed, .today:
                self = .failed
            }
        } else {
            self = .empty
        }
    }
}

private struct CalendarGridCellModel: Identifiable {
    let date: Date
    let dayNumber: Int
    let isSelected: Bool
    let status: CalendarGridCellStatus

    var id: Date { date }
}

private extension SessionSnapshot {
    var hasFailure: Bool {
        exercises
            .flatMap(\.sets)
            .contains { set in
                let hasTarget = set.targetWeight > 0 || set.targetReps > 0
                return hasTarget && !set.metTarget
            }
    }
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
