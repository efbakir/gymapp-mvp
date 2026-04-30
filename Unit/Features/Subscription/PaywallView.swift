//
//  PaywallView.swift
//  Unit
//
//  Post-onboarding paywall. Three tiers: Monthly, Annual, Lifetime.
//  Pricing authority: docs/pricing.md. Calm, light, quiet — no hype.
//

import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var onDismiss: () -> Void

    var body: some View {
        AppScreen(
            primaryButton: PrimaryButtonConfig(
                label: ctaTitle,
                isLoading: store.isLoading,
                action: { Task { await store.purchase() } }
            ),
            secondaryButton: SecondaryButtonConfig(
                label: "Not now",
                action: onDismiss
            ),
            hidesNavigationBar: true
        ) {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Top Area

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Your plan is ready")
                        .font(AppFont.stepIndicator.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .textCase(.uppercase)
                        .tracking(AppFont.smallLabel.tracking)

                    Text("Unlock Unit")
                        .font(AppFont.numericDisplay.font)
                        .tracking(AppFont.numericDisplay.tracking)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .padding(.top, AppSpacing.xl)

                Text("Power-user extras for lifters who already log every session.")
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AppSpacing.smd)

                // MARK: - Benefits
                //
                // Pro feature set per docs/pricing.md and the 2026-04-28 entry
                // in docs/product-compass.md. None of these touch the Gym Test
                // path (logging, ghost values, history, PR detection, widgets)
                // — those stay free forever per docs/claude/scope.md.

                VStack(spacing: 0) {
                    benefitRow("CSV + Markdown export of your training data")
                    benefitRow("Apple Health workout sync")
                    benefitRow("Custom app icons")
                    benefitRow("Custom template accent colors")
                    benefitRow("Founding supporter badge")
                }
                .padding(.top, AppSpacing.xl)

                // MARK: - Tiers

                tierSelector
                    .padding(.top, AppSpacing.xl)

                // MARK: - Footer

                footer
                    .padding(.top, AppSpacing.xl)
            }
            .appScreenEnter()
        }
        .task {
            await store.loadProducts()
        }
        .onChange(of: store.isPurchased) { _, purchased in
            if purchased { onDismiss() }
        }
    }

    // MARK: - CTA title

    private var ctaTitle: String {
        switch store.selectedTier {
        case .monthly, .annual:
            return "Start 7-day free trial"
        case .lifetime:
            return "Unlock Unit Lifetime"
        }
    }

    // MARK: - Benefit Row

    private func benefitRow(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.md) {
            AppIcon.checkmark.image(size: 14, weight: .semibold)
                .foregroundStyle(AppColor.accent)
                .frame(width: 16, alignment: .leading)

            Text(text)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Tier Selector

    private var tierSelector: some View {
        // ViewThatFits falls back to a vertical stack at narrow widths or
        // larger Dynamic Type sizes — on SE (375pt) with three equal-flex
        // cards (~109pt each) labels like "Annually"/"Lifetime" + scaled
        // price text otherwise overflow.
        ViewThatFits {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                tierCards
            }
            VStack(spacing: AppSpacing.sm) {
                tierCards
            }
        }
    }

    @ViewBuilder
    private var tierCards: some View {
        ForEach(StoreManager.Tier.allCases) { tier in
            tierCard(tier: tier)
        }
    }

    private func tierCard(tier: StoreManager.Tier) -> some View {
        let isSelected = store.selectedTier == tier
        let badge = badgeText(for: tier)

        return Button {
            withAnimation(reduceMotion ? nil : .appPress) {
                store.selectedTier = tier
            }
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Badge inside the card top — replaces the prior overflow trick
                // (alignmentGuide straddling ZStack `.top`). Routes through the
                // canonical `AppTag(.accent, .compactCapsule)` so chrome lives
                // in the design system, not paywall-local code.
                if let badge {
                    AppTag(text: badge, style: .accent, layout: .compactCapsule)
                }

                Text(label(for: tier))
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .textCase(.uppercase)
                    .tracking(AppFont.smallLabel.tracking)

                Text(priceText(for: tier))
                    .font(AppFont.productHeading.font)
                    .tracking(AppFont.productHeading.tracking)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)

                Text(sublabel(for: tier))
                    .font(AppFont.muted.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.smd)
            .background(isSelected ? AppColor.accentSoft : AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Tier copy

    private func label(for tier: StoreManager.Tier) -> String {
        switch tier {
        case .lifetime: return "Lifetime"
        case .annual: return "Annually"
        case .monthly: return "Monthly"
        }
    }

    private func priceText(for tier: StoreManager.Tier) -> String {
        if let product = store.product(for: tier) {
            return product.displayPrice
        }
        switch tier {
        case .lifetime: return "$44.99"
        case .annual: return "$29.99"
        case .monthly: return "$4.99"
        }
    }

    private func sublabel(for tier: StoreManager.Tier) -> String {
        switch tier {
        case .lifetime: return "Pay once"
        case .annual: return "~$2.50/mo"
        case .monthly: return "Per month"
        }
    }

    private func badgeText(for tier: StoreManager.Tier) -> String? {
        switch tier {
        case .annual: return "Save 50%"
        default: return nil
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: AppSpacing.sm) {
            // ViewThatFits falls back to vertical stacking on narrow widths
            // / large Dynamic Type. The decorative "·" separators are dropped
            // in the vertical fallback since they only frame the horizontal
            // arrangement.
            ViewThatFits {
                HStack(spacing: AppSpacing.md) {
                    restoreButton
                    middot
                    termsLink
                    middot
                    privacyLink
                }
                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    restoreButton
                    termsLink
                    privacyLink
                }
            }

            Text("Cancelable at any time.")
                .foregroundStyle(AppColor.textSecondary)
        }
        .font(AppFont.caption.font)
        .foregroundStyle(AppColor.textSecondary)
        .frame(maxWidth: .infinity)
    }

    private var restoreButton: some View {
        Button("Restore purchases") {
            Task { await store.restore() }
        }
    }

    @ViewBuilder
    private var termsLink: some View {
        if let termsURL = URL(string: "https://unit.app/terms") {
            Link("Terms", destination: termsURL)
        }
    }

    @ViewBuilder
    private var privacyLink: some View {
        if let privacyURL = URL(string: "https://unit.app/privacy") {
            Link("Privacy", destination: privacyURL)
        }
    }

    private var middot: some View {
        Text("·")
            .foregroundStyle(AppColor.textSecondary)
    }
}

// MARK: - Preview

#Preview {
    PaywallView { }
        .environment(StoreManager())
}
