//
//  OnboardingShell.swift
//  Unit
//
//  Shared onboarding wrapper built on top of AppScreen.
//  Keeps onboarding on the same atom layer: one screen shell, one nav treatment,
//  one sticky primary CTA, one progress component.
//

import SwiftUI

struct OnboardingShell<Content: View, StickyAccessory: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    var subtitle: String? = nil
    var ctaLabel: String = "Continue"
    var ctaEnabled: Bool = true
    var progressStep: Int? = nil
    var progressTotal: Int? = nil
    var onContinue: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content
    /// Optional sticky accessory rendered below the title in the top safe-area inset
    /// (e.g. a horizontal day-chip strip). The title always pins so the entire
    /// header stack remains visible while the body scrolls beneath via `appScrollEdgeSoft`.
    @ViewBuilder var stickyAccessory: () -> StickyAccessory

    private var hasProgressBar: Bool { progressStep != nil && progressTotal != nil }
    private var hasStickyHeader: Bool { StickyAccessory.self != EmptyView.self }

    private var headerStack: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if hasProgressBar {
                    OnboardingProgressBar(
                        step: progressStep ?? 0,
                        total: progressTotal ?? 0
                    )
                }
                titleBlock
                if hasStickyHeader {
                    stickyAccessory()
                }
            }
        )
    }

    @ViewBuilder
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .appFont(.largeTitle)
                .foregroundStyle(AppColor.textPrimary)
                .contentTransition(.opacity)
                .appAnimation(.appReveal, value: title, reduceMotion: reduceMotion)

            if let subtitle {
                Text(subtitle)
                    .appFont(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
                    .appAnimation(.appReveal, value: subtitle, reduceMotion: reduceMotion)
            }
        }
    }

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
            customHeader: headerStack,
            hidesNavigationBar: true,
            showsKeyboardDismissToolbar: false
        ) {
            content()
        }
    }
}

extension OnboardingShell where StickyAccessory == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        ctaLabel: String = "Continue",
        ctaEnabled: Bool = true,
        progressStep: Int? = nil,
        progressTotal: Int? = nil,
        onContinue: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.ctaLabel = ctaLabel
        self.ctaEnabled = ctaEnabled
        self.progressStep = progressStep
        self.progressTotal = progressTotal
        self.onContinue = onContinue
        self.onBack = onBack
        self.content = content
        self.stickyAccessory = { EmptyView() }
    }
}

/// Segmented progress indicator — one capsule per step, filled up to `step`.
/// Centered at the top of the screen. Inactive segments use border color;
/// completed/current segments use `progressSegmentFill` (softer than full `textPrimary`).
struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Capsule()
                    .fill(index < step ? AppColor.progressSegmentFill : AppColor.border)
                    .frame(width: 40, height: 6)
                    .appAnimation(.appReveal, value: step, reduceMotion: reduceMotion)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, AppSpacing.md)
    }
}
