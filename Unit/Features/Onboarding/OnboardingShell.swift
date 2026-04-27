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
    var subtitle: String? = nil
    var ctaLabel: String = "Continue"
    var ctaEnabled: Bool = true
    var progressStep: Int? = nil
    var progressTotal: Int? = nil
    var onContinue: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
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
            secondaryButton: SecondaryButtonConfig(
                label: "Back",
                action: { (onBack ?? { dismiss() })() }
            ),
            customHeader: (progressStep != nil && progressTotal != nil)
                ? AnyView(
                    OnboardingProgressBar(
                        step: progressStep ?? 0,
                        total: progressTotal ?? 0
                    )
                )
                : nil,
            hidesNavigationBar: true
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .appFont(.largeTitle)
                        .foregroundStyle(AppColor.textPrimary)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: title)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textSecondary)
                            .contentTransition(.opacity)
                            .animation(.easeInOut(duration: 0.25), value: subtitle)
                    }
                }

                content()
            }
        }
    }
}

/// Segmented progress indicator — one capsule per step, filled up to `step`.
/// Centered at the top of the screen. Inactive segments use border color;
/// completed/current segments use `progressSegmentFill` (softer than full `textPrimary`).
struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Capsule()
                    .fill(index < step ? AppColor.progressSegmentFill : AppColor.border)
                    .frame(width: 40, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: step)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, AppSpacing.md)
    }
}

struct OnboardingOptionCard: View {
    let icon: AppIcon
    let title: String
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                icon.image(size: 18, weight: .semibold)
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 40, height: 40)
                    .background(AppColor.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                Text(title)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: 0)

                if let badge {
                    AppTag(text: badge, style: .accent, layout: .compactCapsule)
                }
            }
            .appCardStyle()
        }
        .buttonStyle(ScaleButtonStyle())
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
            .background(AppColor.cardBackground)
            .overlay {
                Capsule()
                    .stroke(isSelected ? AppColor.border.opacity(0.6) : Color.clear, lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
