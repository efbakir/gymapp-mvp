//
//  PaywallView.swift
//  Unit
//
//  Post-onboarding paywall. One-time lifetime purchase.
//  Calm, minimal, premium. No hype or urgency.
//

import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - Top Area

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Your plan is ready")
                            .font(AppFont.stepIndicator)
                            .foregroundStyle(AppColor.textSecondary)
                            .textCase(.uppercase)
                            .tracking(AppFont.uppercaseLabelTracking)

                        Text("Unlock Unit")
                            .font(AppFont.display)
                            .tracking(AppFont.displayTracking)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .padding(.top, AppSpacing.xxl)

                    Text("Log workouts fast, track your targets, and see exactly what you lifted last time.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, AppSpacing.smd)

                    // MARK: - Benefits

                    VStack(spacing: 0) {
                        benefitRow(
                            icon: .bolt,
                            title: "Fast workout logging",
                            body: "Log sets in seconds without breaking focus."
                        )

                        benefitRow(
                            icon: .chart,
                            title: "Ghost values",
                            body: "Pre-filled weight and reps from your last session — no typing needed."
                        )

                        benefitRow(
                            icon: .target,
                            title: "Clear targets every session",
                            body: "See exactly what to lift before each set."
                        )

                        benefitRow(
                            icon: .calendarClock,
                            title: "Session history",
                            body: "Review past workouts and stay consistent."
                        )
                    }
                    .padding(.top, AppSpacing.xl)

                    // MARK: - Pricing

                    pricingCard
                        .padding(.top, AppSpacing.xl)

                    // MARK: - CTA

                    VStack(spacing: AppSpacing.smd) {
                        AppPrimaryButton("Unlock Unit Lifetime") {
                            Task { await store.purchase() }
                        }

                        Button(action: onDismiss) {
                            Text("Not now")
                                .font(AppFont.label.font)
                                .foregroundStyle(AppColor.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, AppSpacing.xl)

                    // MARK: - Footer

                    footer
                        .padding(.top, AppSpacing.xl)
                        .padding(.bottom, AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .task {
            await store.loadProduct()
        }
        .onChange(of: store.isPurchased) { _, purchased in
            if purchased { onDismiss() }
        }
    }

    // MARK: - Benefit Row

    private func benefitRow(icon: AppIcon, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            icon.image(size: 16, weight: .semibold)
                .foregroundStyle(AppColor.accent)
                .frame(width: 36, height: 36)
                .background(AppColor.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppFont.label.font)
                    .foregroundStyle(AppColor.textPrimary)

                Text(body)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.smd)
    }

    // MARK: - Pricing Card

    private var pricingCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("One-time purchase")
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)

            HStack(alignment: .lastTextBaseline) {
                Text("Unit Lifetime")
                    .font(AppFont.title.font)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Text(store.product?.displayPrice ?? "€24.99")
                    .font(AppFont.productHeading)
                    .tracking(AppFont.productHeadingTracking)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Text("Pay once. Use it for years.")
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
        }
        .appCardStyle()
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColor.border.opacity(0.6), lineWidth: 1)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: AppSpacing.md) {
            Button("Restore Purchases") {
                Task { await store.restore() }
            }

            Text("·")
                .foregroundStyle(AppColor.textSecondary)

            Link("Terms", destination: URL(string: "https://unit.app/terms")!)

            Text("·")
                .foregroundStyle(AppColor.textSecondary)

            Link("Privacy", destination: URL(string: "https://unit.app/privacy")!)
        }
        .font(AppFont.caption.font)
        .foregroundStyle(AppColor.textSecondary)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    PaywallView { }
        .environment(StoreManager())
}
