//
//  OnboardingShell.swift
//  Unit
//
//  Shared onboarding wrapper built on top of AppScreen.
//  Keeps onboarding on the same atom layer: one screen shell, one nav treatment,
//  one sticky primary CTA, one progress component.
//

import SwiftUI

struct OnboardingShell<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var ctaLabel: String = "Continue"
    var ctaEnabled: Bool = true
    var progressStep: Int? = nil
    var progressTotal: Int? = nil
    var onContinue: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        AppScreen(
            primaryButton: onContinue.map { action in
                PrimaryButtonConfig(
                    label: ctaLabel,
                    isEnabled: ctaEnabled,
                    action: action
                )
            },
            hidesNavigationBar: true
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                OnboardingHeader(
                    progressStep: progressStep,
                    progressTotal: progressTotal,
                    onBack: { dismiss() }
                )

                Text(title)
                    .appFont(.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)

                content()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct OnboardingHeader: View {
    let progressStep: Int?
    let progressTotal: Int?
    let onBack: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Button(action: onBack) {
                AppIcon.back.image(size: 18, weight: .semibold)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let progressStep, let progressTotal {
                OnboardingProgress(step: progressStep, total: progressTotal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OnboardingProgress: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("\(step) of \(total)")
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < step ? AppColor.accent : AppColor.border)
                        .frame(width: index == step - 1 ? 20 : 10, height: 6)
                }
            }
        }
    }
}

struct OnboardingOptionCard: View {
    let icon: AppIcon
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                icon.image(size: 18, weight: .semibold)
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 40, height: 40)
                    .background(AppColor.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppFont.sectionHeader.font)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(subtitle)
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 92, alignment: .leading)
            .padding(AppSpacing.md)
            .background(AppColor.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColor.border.opacity(0.8), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingDayChip: View {
    let name: String
    let isSelected: Bool
    let showsDot: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Text(name)
                    .font(isSelected ? AppFont.label.font : AppFont.body.font)
                    .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                    .lineLimit(1)

                if showsDot {
                    Circle()
                        .fill(AppColor.accent)
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(minHeight: 40)
            .background(isSelected ? AppColor.cardBackground : AppColor.cardBackground)
            .overlay {
                Capsule()
                    .stroke(isSelected ? AppColor.border.opacity(0.6) : Color.clear, lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
