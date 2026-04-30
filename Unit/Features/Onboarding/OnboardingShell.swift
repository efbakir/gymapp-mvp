//
//  OnboardingShell.swift
//  Unit
//
//  Shared onboarding wrapper built on top of AppScreen.
//  Keeps onboarding on the same atom layer: one screen shell, one nav treatment,
//  one sticky primary CTA, one progress component. Sticky chrome stacks
//  back-button → progress → title → optional accessory (e.g. day chips); body
//  scrolls beneath via the canonical `appScrollEdgeSoft` fade.
//
//  Surface: transparent. The Milk page lives once on `OnboardingFlow` so a
//  step swap slides only the content (header + body + sticky CTA) over a
//  still page surface — never the page itself. The shell drops the canonical
//  `appScreenEnter()` because that 6pt fade-up composes with the flow's
//  horizontal slide and reads as double motion.
//

import SwiftUI

struct OnboardingShell<Content: View, StickyAccessory: View, FloatingAccessory: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    var subtitle: String? = nil
    var ctaLabel: String = "Continue"
    var ctaEnabled: Bool = true
    var progressStep: Int? = nil
    var progressTotal: Int? = nil
    var onContinue: (() -> Void)? = nil
    /// Back action is owned by `OnboardingFlow` (state-driven coordinator);
    /// every step gets one wired explicitly so there is no environment-dismiss
    /// fallback to drift to.
    let onBack: () -> Void
    @ViewBuilder var content: () -> Content
    /// Optional sticky accessory rendered below the title in the top safe-area
    /// inset (e.g. a horizontal day-chip strip). Stays pinned while the body
    /// scrolls beneath via `appScrollEdgeSoft`.
    @ViewBuilder var stickyAccessory: () -> StickyAccessory
    /// Optional capsule pill that hovers above the primary CTA. Auto-hides on
    /// scroll-down, reveals on scroll-up. Built from `AppFloatingPillButton`.
    @ViewBuilder var floatingAccessory: () -> FloatingAccessory

    private var hasProgressBar: Bool { progressStep != nil && progressTotal != nil }
    private var hasStickyAccessory: Bool { StickyAccessory.self != EmptyView.self }
    private var hasFloatingAccessory: Bool { FloatingAccessory.self != EmptyView.self }

    private var headerStack: AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: 0) {
                    OnboardingBackButton(action: onBack)
                    Spacer(minLength: 0)
                }
                if hasProgressBar {
                    OnboardingProgressBar(
                        step: progressStep ?? 0,
                        total: progressTotal ?? 0
                    )
                }
                titleBlock
                if hasStickyAccessory {
                    // Width clamping for horizontal-scrolling accessories
                    // (e.g. `AppFilterChipBar`) lives at the atom layer so the
                    // unbounded ideal width never leaks through this VStack
                    // and cancels `AppScreen`'s canonical 16pt screen padding.
                    // No screen-side workaround required.
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
            customHeader: headerStack,
            floatingAccessory: hasFloatingAccessory ? AnyView(floatingAccessory()) : nil,
            hidesNavigationBar: true,
            showsKeyboardDismissToolbar: false,
            surface: nil
        ) {
            content()
        }
    }
}

extension OnboardingShell where StickyAccessory == EmptyView, FloatingAccessory == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        ctaLabel: String = "Continue",
        ctaEnabled: Bool = true,
        progressStep: Int? = nil,
        progressTotal: Int? = nil,
        onContinue: (() -> Void)? = nil,
        onBack: @escaping () -> Void,
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
        self.floatingAccessory = { EmptyView() }
    }
}

extension OnboardingShell where FloatingAccessory == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        ctaLabel: String = "Continue",
        ctaEnabled: Bool = true,
        progressStep: Int? = nil,
        progressTotal: Int? = nil,
        onContinue: (() -> Void)? = nil,
        onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder stickyAccessory: @escaping () -> StickyAccessory
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
        self.stickyAccessory = stickyAccessory
        self.floatingAccessory = { EmptyView() }
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
        onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder floatingAccessory: @escaping () -> FloatingAccessory
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
        self.floatingAccessory = floatingAccessory
    }
}

/// Native iOS-style back button — chevron + "Back" label. Used at top-leading
/// of every onboarding step's `customHeader`. The shell's flow is custom
/// (state-driven coordinator, not `NavigationStack`), so this stand-in mirrors
/// the system-bar treatment without the bar itself.
private struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                AppIcon.back.image(size: 17, weight: .semibold)
                Text("Back")
                    .font(AppFont.body.font.weight(.semibold))
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

/// Page-corner numeric counter — `STEP 02 / 04`.
/// Replaces the old segmented capsule bar. Mono digits (Geist Mono SemiBold 14
/// via `AppFont.stepIndicator`) make the count the loudest element instead of
/// chrome. Current digit reads in Ink, total in Mist, label in Ash — three
/// weights of meaning on one line. Leading-aligned with the title underneath.
struct OnboardingProgressBar: View {
    let step: Int
    let total: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var clampedStep: Int { max(1, min(step, max(total, 1))) }
    private var stepText: String { String(format: "%02d", clampedStep) }
    private var totalText: String { String(format: "%02d", max(total, 1)) }

    var body: some View {
        HStack(spacing: 0) {
            Text("STEP ")
                .foregroundStyle(AppColor.textSecondary)
            Text(stepText)
                .foregroundStyle(AppColor.textPrimary)
                .contentTransition(.numericText())
                .appAnimation(.appReveal, value: clampedStep, reduceMotion: reduceMotion)
            Text(" / \(totalText)")
                .foregroundStyle(AppColor.textDisabled)
        }
        .font(AppFont.stepIndicator.font)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(clampedStep) of \(max(total, 1))")
    }
}
