//
//  ExerciseProgressView.swift
//  Unit
//
//  Exercise-focused progress: PR stat, weight timeline chart, per-session delta list.
//

import Charts
import SwiftUI

struct ExerciseProgressView: View {
    let exerciseId: UUID
    let exerciseName: String
    let isBodyweight: Bool
    let sessions: [WorkoutSession]
    let templates: [DayTemplate]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    struct SessionPoint: Identifiable {
        let id: UUID
        let date: Date
        let weight: Double
        let reps: Int
        let templateId: UUID
    }

    private struct SessionRowItem: Identifiable {
        let point: SessionPoint
        let prev: SessionPoint?
        var id: UUID { point.id }
    }

    private static let sessionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    // Best set per completed session (highest weight, then reps)
    private var sessionPoints: [SessionPoint] {
        sessions
            .filter(\.isCompleted)
            .compactMap { session -> SessionPoint? in
                let best = session.setEntries
                    .filter { $0.exerciseId == exerciseId && $0.isCompleted && !$0.isWarmup }
                    .max { lhs, rhs in lhs.weight == rhs.weight ? lhs.reps < rhs.reps : lhs.weight < rhs.weight }
                guard let best else { return nil }
                return SessionPoint(id: session.id, date: session.date, weight: best.weight, reps: best.reps, templateId: session.templateId)
            }
            .sorted { $0.date < $1.date }
    }

    private var allTimePR: SessionPoint? {
        sessionPoints.max { lhs, rhs in lhs.weight == rhs.weight ? lhs.reps < rhs.reps : lhs.weight < rhs.weight }
    }

    private var epley1RM: Double? {
        guard let pr = allTimePR else { return nil }
        guard pr.reps > 1 else { return pr.weight }
        return pr.weight * (1.0 + Double(pr.reps) / 30.0)
    }

    var body: some View {
        AppScreen(
            showsNativeNavigationBar: true
        ) {
            if let pr = allTimePR, let e1rm = epley1RM {
                prCard(pr: pr, e1rm: e1rm)
            }

            if sessionPoints.count > 1 {
                chartCard
            }

            if !sessionPoints.isEmpty {
                sessionListCard
            } else {
                EmptyStateCard(
                    title: "No data yet",
                    message: "Sets logged for \(exerciseName) will appear here as a chart and session history."
                )
            }
        }
        .navigationBarTitleTruncated(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarChrome()
    }

    // MARK: - PR Card

    private func prCard(pr: SessionPoint, e1rm: Double) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Best Set")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                Text(WorkoutTargetFormatter.actualText(weightKg: pr.weight, setCount: 1, reps: pr.reps, isBodyweight: isBodyweight))
                    .font(AppFont.title.font)
                    .monospacedDigit()
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("Est. 1RM")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                Text(WorkoutTargetFormatter.weightDisplay(e1rm))
                    .font(AppFont.title.font)
                    .monospacedDigit()
            }
        }
        .appCardStyle()
    }

    // MARK: - Chart

    private var chartCard: some View {
        SettingsSection(title: "Weight Over Time") {
            Chart(sessionPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Weight (kg)", point.weight)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(AppColor.textPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2))

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Weight (kg)", point.weight)
                )
                .foregroundStyle(AppColor.textPrimary)
                .symbolSize(30)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                    AxisGridLine()
                        .foregroundStyle(AppColor.border.opacity(0.4))
                }
            }
            .frame(height: 160)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: exerciseName)
        }
    }

    // MARK: - Session list

    private var sessionRowItems: [SessionRowItem] {
        let reversed = Array(sessionPoints.reversed())
        return reversed.enumerated().map { idx, point in
            let prev = reversed.dropFirst(idx + 1).first { $0.templateId == point.templateId }
            return SessionRowItem(point: point, prev: prev)
        }
    }

    private var sessionListCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader("Sessions")
            AppCardList(sessionRowItems) { item in
                sessionRow(point: item.point, prev: item.prev)
            }
        }
    }

    private func sessionRow(point: SessionPoint, prev: SessionPoint?) -> some View {
        let templateName = templates.first(where: { $0.id == point.templateId })?.name ?? "Session"
        let delta = prev.map { point.weight - $0.weight }

        return HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(templateName)
                    .font(AppFont.body.font)
                    .lineLimit(1)
                Text(Self.sessionDateFormatter.string(from: point.date))
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                Text(WorkoutTargetFormatter.actualText(weightKg: point.weight, setCount: 1, reps: point.reps, isBodyweight: isBodyweight))
                    .font(AppFont.body.font)
                    .monospacedDigit()
                if let d = delta {
                    if d > 0 {
                        Text("+\(WorkoutTargetFormatter.weightDisplay(d))")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.success)
                            .monospacedDigit()
                    } else if d < 0 {
                        Text("-\(WorkoutTargetFormatter.weightDisplay(abs(d)))")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.error)
                            .monospacedDigit()
                    } else {
                        Text("No change")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
