//
//  OnboardingCycleStartView.swift
//  Unit
//
//  Screen 8 — Program start date.
//  This is the commit point: creates the program and writes data to SwiftData.
//

import SwiftUI

struct OnboardingCycleStartView: View {
    @Environment(OnboardingViewModel.self) private var vm
    var progressStep: Int
    var progressTotal: Int
    var onCreateCycle: () -> Void

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    // End date removed: 8-week cycles demoted per compass 2026-03-26.

    var body: some View {
        @Bindable var vm = vm

        OnboardingShell(
            title: "Start date",
            ctaLabel: "Continue",
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onCreateCycle
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {

                // Start options
                StartOptionRow(
                    label: "Today",
                    detail: dateFormatter.string(from: todayDate()),
                    isSelected: vm.startOption == .today
                ) {
                    selectStartOption(.today)
                }

                StartOptionRow(
                    label: "Next Monday",
                    detail: dateFormatter.string(from: nextMondayDate()),
                    isSelected: vm.startOption == .nextMonday
                ) {
                    selectStartOption(.nextMonday)
                }

                // Custom date option
                VStack(spacing: 0) {
                    StartOptionRow(
                        label: "Pick a date",
                        detail: vm.startOption == .custom ? dateFormatter.string(from: vm.customDate) : "",
                        isSelected: vm.startOption == .custom
                    ) {
                        selectStartOption(.custom)
                    }

                    if vm.startOption == .custom {
                        DatePicker(
                            "",
                            selection: $vm.customDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(AppColor.accent)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.sm)
                    }
                }
                .background(AppColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))

                // "Estimated end date" card removed — 8-week cycles demoted per compass 2026-03-26.
            }
        }
    }

    private func todayDate() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    private func nextMondayDate() -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date())
        let days = weekday == 2 ? 7 : (9 - weekday) % 7
        return cal.date(byAdding: .day, value: days, to: cal.startOfDay(for: Date())) ?? Date()
    }

    private func selectStartOption(_ option: OnboardingViewModel.StartOption) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            vm.startOption = option
        }
    }
}

// MARK: - Start Option Row

private struct StartOptionRow: View {
    let label: String
    let detail: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? AppColor.accent : AppColor.border,
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(AppColor.accent)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(label)
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textPrimary)
                    if !detail.isEmpty {
                        Text(detail)
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        OnboardingCycleStartView(progressStep: 6, progressTotal: 6) { }
            .environment(OnboardingViewModel())
    }
    .tint(AppColor.accent)
}
