//
//  OnboardingProgressionView.swift
//  Unit
//
//  Screen 7 — Default increment.
//  Global only — per-exercise overrides may be added post-launch.
//

import SwiftUI

struct OnboardingProgressionView: View {
    @Environment(OnboardingViewModel.self) private var vm
    var progressStep: Int
    var progressTotal: Int
    var onContinue: () -> Void

    var body: some View {
        OnboardingShell(
            title: "Default increment",
            ctaLabel: "Continue",
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.sm) {
                    IncrementSelectorRow(
                        title: "Main lifts",
                        value: vm.incrementDisplayLabel(for: .compound),
                        onDecrease: { vm.stepDown(.compound) },
                        onIncrease: { vm.stepUp(.compound) }
                    )

                    IncrementSelectorRow(
                        title: "Isolation",
                        value: vm.incrementDisplayLabel(for: .isolation),
                        onDecrease: { vm.stepDown(.isolation) },
                        onIncrease: { vm.stepUp(.isolation) }
                    )
                }
                .padding(AppSpacing.md)
                .background(AppColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))

                Text("Main lifts usually start at 2.5–5 \(vm.weightUnitLabel). Isolation usually stays at 0–2.5 \(vm.weightUnitLabel), including 0 if you want it fixed.")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}

private struct IncrementSelectorRow: View {
    let title: String
    let value: String
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppColor.textPrimary)

            HStack {
                Button(action: onDecrease) {
                    AppIcon.remove.image(size: 16, weight: .semibold)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(AppColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }

                Spacer()

                Text(value)
                    .font(AppFont.numericLarge)
                    .tracking(AppFont.numericLargeTracking)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Button(action: onIncrease) {
                    AppIcon.add.image(size: 16, weight: .semibold)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(AppColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingProgressionView(progressStep: 5, progressTotal: 6) { }
            .environment(OnboardingViewModel())
    }
    .tint(AppColor.accent)
}
