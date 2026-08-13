//
//  PaywallView.swift
//  Unit
//
//  Hard paywall presented after onboarding, before first workout log.
//  Weekly, Monthly, Yearly subscriptions plus optional Lifetime purchase.
//  Eligible Monthly and Yearly products may carry a StoreKit-confirmed
//  introductory trial. No dismissal.
//  Pricing authority: docs/pricing.md.
//

import StoreKit
import SwiftData
import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    // Personalization (founder-approved conversion pass, 2026-07-13): the
    // paywall names the program the user just built, so the screen reads as
    // the payoff of their onboarding effort, not a generic wall.
    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \DayTemplate.name) private var templates: [DayTemplate]
    @State private var showingManageSubscriptions = false
    @State private var didTrackView = false
    @State private var isPlanPickerExpanded = false
    var onDismiss: () -> Void

    var body: some View {
        // Hard paywall with no secondary escape. `onDismiss` is invoked only
        // by a verified purchase below.
        AppScreen(
            primaryButton: primaryButtonConfig,
            hidesNavigationBar: true,
            showsTopScrollFade: false
        ) {
            // No .appScreenEnter() here: the root gate owns the transition.
            // Adding a second opacity-0→1 entrance risks the content staying
            // invisible if onAppear misfires on iOS 26's re-present cycle.
            if store.isPurchased {
                activeSubscriptionContent
            } else {
                purchaseContent
            }
        }
        .manageSubscriptionsSheet(isPresented: $showingManageSubscriptions)
        .sheet(isPresented: $isPlanPickerExpanded) {
            planPickerSheet
        }
        .task {
            await store.loadProducts()
            guard !didTrackView else { return }
            didTrackView = true
            let eligibility = selectedTrial == nil
                ? (store.hasCheckedIntroOfferEligibility ? "ineligible" : "unknown")
                : "eligible"
            UnitAnalytics.shared.track(.paywallViewed(trialEligibility: eligibility))
        }
        .onChange(of: store.isPurchased) { _, purchased in
            if purchased { onDismiss() }
        }
        .appHaptic(.purchaseSuccess, trigger: store.isPurchased) { old, new in
            !old && new
        }
        .appHaptic(.tierSelected, trigger: store.selectedTier)
        .alert(
            "Something went wrong",
            isPresented: errorAlertBinding,
            presenting: store.purchaseError
        ) { _ in
            Button("OK", role: .cancel) { store.purchaseError = nil }
        } message: { error in
            Text(error)
        }
        .alert(
            "Restore",
            isPresented: infoAlertBinding,
            presenting: store.infoMessage
        ) { _ in
            Button("OK", role: .cancel) { store.infoMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { store.purchaseError != nil },
            set: { if !$0 { store.purchaseError = nil } }
        )
    }

    private var infoAlertBinding: Binding<Bool> {
        Binding(
            get: { store.infoMessage != nil },
            set: { if !$0 { store.infoMessage = nil } }
        )
    }

    // MARK: - Content

    private var purchaseContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            purchaseHeader

            programSummaryCard
                .padding(.top, AppSpacing.lg)

            if hasNoLoadedProducts {
                loadFailureBanner
                    .padding(.top, AppSpacing.lg)
            } else {
                planSelectionSection
                    .padding(.top, AppSpacing.xl)

                if store.hasAttemptedProductLoad && hasMissingRequiredProducts && !store.isLoading {
                    partialLoadBanner
                        .padding(.top, AppSpacing.md)
                }

                purchaseTimelineSection
                    .padding(.top, AppSpacing.xl)
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Everything included")
                    .font(AppFont.muted.font)
                    .foregroundStyle(AppColor.textSecondary)

                AppFeatureAccessTable(rows: AppCopy.Paywall.includedFeatures)
            }
            .padding(.top, AppSpacing.xl)

            if !hasNoLoadedProducts {
                subscriptionDisclosure
                    .padding(.top, AppSpacing.sm)
            }

            footer
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
        }
    }

    private var activeSubscriptionContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            activeSubscriptionHeader

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.smd) {
                    Text("Current plan")
                        .font(AppFont.sectionHeader.font)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Current plan: \(activePlanName)")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, AppSpacing.xl)

            if canManageActiveSubscription {
                AppGhostButton("Manage Subscription") {
                    showingManageSubscriptions = true
                }
                .padding(.top, AppSpacing.md)
            }

            footer
                .padding(.top, AppSpacing.xl)
        }
    }

    private var purchaseHeader: some View {
        VStack(alignment: .center, spacing: AppSpacing.xs) {
            Text(paywallHeadline)
                .appFont(.title)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("paywall-headline")

            Text(paywallSupportingCopy)
                .font(AppFont.muted.font)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("paywall-supporting-copy")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, AppSpacing.sm)
    }

    private var selectedPresentation: StorePlanPresentation? {
        store.presentation(for: store.selectedTier)
    }

    private var selectedTrial: StorePlanPresentation.Trial? {
        selectedPresentation?.trial
    }

    @ViewBuilder
    private var purchaseTimelineSection: some View {
        if !purchaseTimelineItems.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.smd) {
                Text(purchaseTimelineTitle)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                AppTimeline(items: purchaseTimelineItems)
                    .accessibilityIdentifier("paywall-timeline")
            }
        }
    }

    private var purchaseTimelineTitle: String {
        if selectedTrial != nil {
            return AppCopy.Paywall.trialTimelineTitle
        }
        if store.selectedTier == .lifetime {
            return AppCopy.Paywall.lifetimeTimelineTitle
        }
        return AppCopy.Paywall.timelineTitle
    }

    private var purchaseTimelineItems: [AppTimelineItem] {
        guard let presentation = selectedPresentation else { return [] }

        if let trial = presentation.trial {
            return [
                AppTimelineItem(
                    id: "trial-day-zero",
                    title: AppCopy.Paywall.trialTimelineDayZeroTitle,
                    subtitle: AppCopy.Paywall.trialTimelineDayZeroMessage,
                    icon: .bolt,
                    isCurrent: true
                ),
                AppTimelineItem(
                    id: "trial-before-end",
                    title: AppCopy.Paywall.trialTimelineBeforeRenewalTitle(
                        dayCount: trial.dayCount
                    ),
                    subtitle: AppCopy.Paywall.timelineBeforeRenewalMessage,
                    icon: .settingsOutline
                ),
                AppTimelineItem(
                    id: "trial-end",
                    title: AppCopy.Paywall.trialTimelineEndTitle(
                        dayCount: trial.dayCount
                    ),
                    subtitle: AppCopy.Paywall.trialTimelineEndMessage(
                        presentation.billedPriceText
                    ),
                    icon: .calendarClock
                )
            ]
        }

        if store.selectedTier == .lifetime {
            return [
                AppTimelineItem(
                    id: "lifetime-today",
                    title: AppCopy.Paywall.timelineTodayTitle,
                    subtitle: AppCopy.Paywall.lifetimeTodayMessage,
                    icon: .bolt,
                    isCurrent: true
                ),
                AppTimelineItem(
                    id: "lifetime-payment",
                    title: AppCopy.Paywall.lifetimePaymentTitle,
                    subtitle: AppCopy.Paywall.lifetimePaymentMessage(
                        presentation.displayPrice
                    ),
                    icon: .checkmarkFilled
                )
            ]
        }

        return [
            AppTimelineItem(
                id: "subscription-today",
                title: AppCopy.Paywall.timelineTodayTitle,
                subtitle: AppCopy.Paywall.timelineTodayMessage,
                icon: .bolt,
                isCurrent: true
            ),
            AppTimelineItem(
                id: "subscription-before-renewal",
                title: AppCopy.Paywall.timelineBeforeRenewalTitle,
                subtitle: AppCopy.Paywall.timelineBeforeRenewalMessage,
                icon: .settingsOutline
            ),
            AppTimelineItem(
                id: "subscription-renewal",
                title: AppCopy.Paywall.timelineRenewalTitle(
                    presentation.billingPeriodText
                ),
                subtitle: AppCopy.Paywall.timelineRenewalMessage(
                    presentation.billedPriceText
                ),
                icon: .calendarClock
            )
        ]
    }

    private var paywallHeadline: String {
        guard let selectedTrial else { return AppCopy.Paywall.standardHeadline }
        return AppCopy.Paywall.trialHeadline(selectedTrial.durationText)
    }

    private var paywallSupportingCopy: String {
        selectedTrial == nil
            ? AppCopy.Paywall.standardSupportingCopy
            : AppCopy.Paywall.trialSupportingCopy
    }

    private var programSummaryCard: some View {
        AppCard(contentInset: AppSpacing.md, verticalInset: AppSpacing.smd) {
            VStack(alignment: .center, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    AppIcon.checkmarkFilled.image(size: 16)
                        .foregroundStyle(AppColor.accent)

                    Text(programStatusLabel)
                        .appCapsLabel(.smallLabel)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Text(programTitle)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let programContextLine {
                    Text(programContextLine)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var activeSubscriptionHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smd) {
            Text("Unit Pro active")
                .appFont(.largeTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(activeSubscriptionSubtitle)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, AppSpacing.xl)
    }

    private var programStatusLabel: String {
        setupContext?.matchProfile == nil
            ? AppCopy.Paywall.programReady
            : AppCopy.Paywall.programMatched
    }

    private var programContextLine: String? {
        setupContext?.matchProfile?.summary ?? programDayLine
    }

    private var setupContext: ProgramSetupContext? {
        ProgramSetupContextStore.load()
    }

    private var activeSubscriptionSubtitle: String {
        if store.activeTier == .lifetime {
            return "Lifetime access is active. Restore purchases anytime with the same Apple Account."
        }
        return "Your subscription is active. Manage or cancel anytime in App Store settings."
    }

    private var orderedProgramTemplates: [DayTemplate] {
        guard let split = ActiveSplitStore.resolve(from: splits) else { return [] }
        let splitTemplates = templates.filter { $0.splitId == split.id }
        let byID = Dictionary(uniqueKeysWithValues: splitTemplates.map { ($0.id, $0) })
        let ordered = split.orderedTemplateIds.compactMap { byID[$0] }
        return ordered.isEmpty ? splitTemplates.sorted { $0.name < $1.name } : ordered
    }

    private var programTitle: String {
        guard let split = ActiveSplitStore.resolve(from: splits) else {
            return AppCopy.Paywall.programFallbackTitle
        }
        let names = orderedProgramTemplates.map(\.displayName).filter { !$0.isEmpty }
        guard !names.isEmpty else { return AppCopy.Paywall.programFallbackTitle }
        let generatedName = names.joined(separator: " / ")
        let savedName = split.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if savedName.isEmpty || savedName == generatedName {
            return AppCopy.Paywall.programDayCount(names.count)
        }
        return savedName
    }

    private var programDayLine: String? {
        let names = orderedProgramTemplates.map(\.displayName).filter { !$0.isEmpty }
        guard !names.isEmpty else { return nil }

        if names.count > 4 {
            let visibleNames = names.prefix(3).joined(separator: " · ")
            return "\(visibleNames) · \(names.count - 3) more"
        }

        return names.joined(separator: " · ")
    }

    // MARK: - CTA

    private var primaryButtonConfig: PrimaryButtonConfig? {
        guard !store.isPurchased else { return nil }
        return PrimaryButtonConfig(
            label: ctaTitle,
            isEnabled: store.selectedProduct != nil && !store.isBusy,
            isLoading: store.isLoading || store.isPurchasing,
            disabledReason: ctaDisabledReason,
            contextLabel: selectedPurchaseContext,
            action: { Task { await store.purchase() } }
        )
    }

    private var ctaTitle: String {
        if hasNoLoadedProducts {
            return "Subscribe to continue"
        }

        if let selectedTrial {
            return AppCopy.Paywall.startFreeTrial(selectedTrial.adjectiveText)
        }

        switch store.selectedTier {
        case .weekly: return AppCopy.Paywall.subscribeWeekly
        case .monthly: return AppCopy.Paywall.subscribeMonthly
        case .annual: return AppCopy.Paywall.subscribeYearly
        case .lifetime: return AppCopy.Paywall.buyLifetime
        }
    }

    private var ctaDisabledReason: String? {
        if store.isPurchasePending {
            return AppCopy.Paywall.pendingPurchaseContext
        }
        if hasNoLoadedProducts {
            return "Subscriptions couldn't load. Try again."
        }
        if store.hasAttemptedProductLoad {
            return "Choose an available plan."
        }
        return "Loading subscriptions."
    }

    private var selectedPurchaseContext: String? {
        guard let presentation = store.presentation(for: store.selectedTier) else { return nil }
        if let trial = presentation.trial {
            return AppCopy.Paywall.trialPurchaseContext(
                duration: trial.durationText,
                billedPrice: presentation.billedPriceText
            )
        }
        if store.selectedTier == .lifetime {
            return AppCopy.Paywall.lifetimePurchaseContext(presentation.displayPrice)
        }
        return AppCopy.Paywall.subscriptionPurchaseContext(presentation.billedPriceText)
    }

    // MARK: - Tier Selector

    private var planSelectionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(AppCopy.Paywall.yourPlan)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: AppSpacing.sm)

                Button("Change") {
                    isPlanPickerExpanded = true
                }
                .font(AppFont.muted.font)
                .foregroundStyle(AppColor.accent)
                .frame(minHeight: 44)
                .accessibilityIdentifier("paywall-plan-picker-toggle")
            }

            selectedTierCard
        }
    }

    private var planPickerSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xs) {
                    tierCards
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle(AppCopy.Paywall.choosePlan)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPlanPickerExpanded = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var selectedTierCard: some View {
        AppSelectableTierCard(
            label: label(for: store.selectedTier),
            price: priceText(for: store.selectedTier),
            sublabel: sublabel(for: store.selectedTier),
            badge: badgeText(for: store.selectedTier),
            isSelected: true,
            isEnabled: store.product(for: store.selectedTier) != nil,
            accessibilityHint: "Show all plans",
            action: {
                isPlanPickerExpanded = true
            }
        )
        .accessibilityIdentifier("paywall-plan-\(store.selectedTier.rawValue)")
    }

    @ViewBuilder
    private var tierCards: some View {
        ForEach(visibleTiers) { tier in
            AppSelectableTierCard(
                label: label(for: tier),
                price: priceText(for: tier),
                sublabel: sublabel(for: tier),
                badge: badgeText(for: tier),
                isSelected: store.selectedTier == tier,
                isEnabled: store.product(for: tier) != nil,
                action: {
                    store.selectTier(tier)
                    isPlanPickerExpanded = false
                }
            )
            .accessibilityIdentifier("paywall-plan-\(tier.rawValue)")
        }
    }

    private var visibleTiers: [StoreManager.Tier] {
        var tiers = StoreManager.requiredTiers
        if store.product(for: .lifetime) != nil {
            tiers.append(.lifetime)
        }
        return tiers
    }

    private var hasMissingRequiredProducts: Bool {
        StoreManager.requiredTiers.contains { store.product(for: $0) == nil }
    }

    private var hasNoLoadedProducts: Bool {
        store.hasAttemptedProductLoad && store.products.isEmpty && !store.isLoading
    }

    private var canManageActiveSubscription: Bool {
        guard let activeTier = store.activeTier else { return store.isPurchased }
        return activeTier.isSubscription
    }

    // MARK: - Tier copy

    private func label(for tier: StoreManager.Tier) -> String {
        switch tier {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    private func priceText(for tier: StoreManager.Tier) -> String {
        if let presentation = store.presentation(for: tier) {
            return presentation.billedPriceText
        }
        return store.hasAttemptedProductLoad ? "Unavailable" : "Loading…"
    }

    private func sublabel(for tier: StoreManager.Tier) -> String {
        if let presentation = store.presentation(for: tier),
           let trial = presentation.trial {
            return "\(trial.durationText) free · then \(presentation.billedPriceText)"
        }

        switch tier {
        case .weekly: return "Auto-renews weekly"
        case .monthly:
            if let perWeek = perWeekEquivalentText(for: .monthly) {
                return "Auto-renews monthly · \(perWeek)/week"
            }
            return "Auto-renews monthly"
        case .annual:
            if let perWeek = perWeekEquivalentText(for: .annual) {
                return "Auto-renews yearly · \(perWeek)/week"
            }
            return "Auto-renews yearly"
        case .lifetime: return "One-time purchase"
        }
    }

    /// Every recurring card priced in the unit the pre-selected Weekly tier
    /// anchors on, derived from live StoreKit prices in the product's own
    /// currency ($2.99/week vs $1.15/week vs $0.58/week). Real division only
    /// — never a hardcoded compare-at figure.
    private func perWeekEquivalentText(for tier: StoreManager.Tier) -> String? {
        guard let product = store.product(for: tier) else { return nil }
        let perWeek: Decimal
        switch tier {
        case .monthly: perWeek = product.price * 12 / 52
        case .annual: perWeek = product.price / 52
        case .weekly, .lifetime: return nil
        }
        return perWeek.formatted(product.priceFormatStyle)
    }

    private func badgeText(for tier: StoreManager.Tier) -> String? {
        // docs/pricing.md ladder roles: yearly is the best-value tier and the
        // only badged card — one chip on the upsell target, never on the
        // pre-selected default (a badge on the selected card sells nothing).
        guard tier == .annual, store.product(for: tier) != nil else { return nil }
        return annualSavingsBadgeText ?? "Best value"
    }

    /// "Save 80%" — calculated against 52 weeks at the live Weekly price.
    /// The compact badge omits the comparison label; the yearly card already
    /// shows its per-week equivalent directly beneath the price.
    private var annualSavingsBadgeText: String? {
        guard let annual = store.product(for: .annual),
              let weekly = store.product(for: .weekly) else { return nil }
        let annualizedWeekly = weekly.price * 52
        guard annualizedWeekly > annual.price, annualizedWeekly > 0 else { return nil }
        let fraction = (annualizedWeekly - annual.price) / annualizedWeekly
        let percent = Int((NSDecimalNumber(decimal: fraction).doubleValue * 100).rounded(.down))
        guard percent >= 10 else { return nil }
        return "Save \(percent)%"
    }

    private func ctaPlanName(for tier: StoreManager.Tier) -> String {
        switch tier {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    private var activePlanName: String {
        guard let activeTier = store.activeTier else { return "Active" }
        return ctaPlanName(for: activeTier)
    }

    // MARK: - Subscription Disclosure
    //
    // Apple Guideline 3.1.2(b): the purchase surface must disclose
    // subscription title, period, auto-renewal language, and how to cancel.
    // Trial language appears only when `StorePlanPresentation.trial` proves a
    // configured free offer and current-customer eligibility.

    private var subscriptionDisclosure: some View {
        Text(disclosureCopy)
            .font(AppFont.muted.font)
            .foregroundStyle(AppColor.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var disclosureCopy: String {
        if store.selectedTier == .lifetime {
            return "Lifetime is a one-time purchase. Subscriptions auto-renew unless cancelled. Payment is charged to your Apple Account. You can manage or cancel your subscription in App Store settings."
        }
        if selectedTrial != nil {
            return "After the free trial, the subscription auto-renews unless cancelled. Payment is charged to your Apple Account. You can manage or cancel in App Store settings."
        }
        return "Subscriptions auto-renew unless cancelled. Payment is charged to your Apple Account. You can manage or cancel your subscription in App Store settings."
    }

    // MARK: - Load failure banner
    //
    // Shown when StoreKit product loading has finished but products are empty
    // (network failure, App Store outage). Without this, the disabled CTA
    // would leave the user with no recovery path.

    private var loadFailureBanner: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Couldn't load subscriptions")
                        .font(AppFont.sectionHeader.font)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("The App Store couldn't load subscriptions. Try again in a moment.")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                AppGhostButton("Try again") {
                    Task { await store.loadProducts(force: true) }
                }
            }
        }
    }

    private var partialLoadBanner: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Some plans couldn't load.")
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)
            AppGhostButton("Try again") {
                Task { await store.loadProducts(force: true) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: AppSpacing.sm) {
            // ViewThatFits(in: .horizontal) — same axis rationale as
            // tierSelector above. Decorative "·" separators are dropped in
            // the vertical fallback since they only frame horizontal layout.
            ViewThatFits(in: .horizontal) {
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
        }
        .font(AppFont.caption.font)
        .foregroundStyle(AppColor.textSecondary)
        .frame(maxWidth: .infinity)
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text("Restore Purchases")
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .disabled(store.isBusy)
    }

    @ViewBuilder
    private var termsLink: some View {
        if let termsURL = AppCopy.Legal.termsOfServiceURL {
            Link(destination: termsURL) {
                Text(AppCopy.Legal.termsOfService)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
        }
    }

    @ViewBuilder
    private var privacyLink: some View {
        if let privacyURL = AppCopy.Legal.privacyPolicyURL {
            Link(destination: privacyURL) {
                Text(AppCopy.Legal.privacyPolicy)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
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
