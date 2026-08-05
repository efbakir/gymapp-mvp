# Onboarding → Paywall — release QA report

> **Historical snapshot with current addendum.** Sections A–I record the 2026-07-01/11
> verification state. The 2026-08-04 automated release-gate addendum at the end is the current
> repository evidence and supersedes the older machine-verification gaps.

- **Date:** 2026-07-01
- **Branch:** `release/onboarding-paywall-qa`
- **Scope:** onboarding splash → program setup → hard paywall (the flow gated by `ContentView`).
- **Environment:** Xcode 26.3, iOS Simulator. Mac in active use → simulator driven for screenshots only (no synthetic input), so deep interactive states are documented as a manual walk rather than machine-driven.

## A) Goal status

**Historical 2026-07-01 status: incomplete — code/build/tests/onboarding-start verified; loaded-paywall on 3 sizes + purchase-unlock still required a documented ~10-min manual Xcode walk.**

At that time, the flow audited **clean** (no duplicate/unreachable CTAs, no misleading price/trial copy, no coaching language, StoreKit states all recoverable, design-system-conformant). Build and tests passed. Onboarding launch/render was screenshot-verified. The two criteria requiring a running StoreKit purchase — **#6 paywall layout on small/normal/large** and **#8 purchase unlock** — were not yet machine-verified (see §I). The 2026-08-04 addendum closes those repository-controlled gaps.

## B) Branch / commits

- Branch `release/onboarding-paywall-qa`, off local `main` (carries the 2 previously-unpushed `main` commits `bc39ce1`, `dcd588d`, per founder OK).
- Pushed to `origin`. See `git log` for the QA commit SHA.

## C) Files changed

Pre-existing uncommitted paywall work (included per founder decision — legitimate QA improvements):
- `Unit/Features/Subscription/PaywallView.swift` — load-failure recovery card, `hasNoLoadedProducts` state, clearer CTA/disabled copy, `visibleTiers` filters to loaded tiers.
- `Unit/Features/Subscription/StoreManager.swift` — auto-selects first available tier after load so the CTA is never stuck disabled.
- `Unit/UI/DesignSystem.swift` — tighter `AppSelectableTierCard` spacing so tiers + legal + CTA fit without clipping.

This QA pass:
- `Unit/Features/Onboarding/OnboardingProgramPreviewView.swift` — stale-comment fixes (CTA is "Choose a plan" → paywall; inline weight field renders empty, not "—").
- `Unit/Features/Onboarding/OnboardingViewModel.swift` — stale-comment fix (commit trigger).
- `Unit/Unit.storekit` — **new** dev-only StoreKit config (weekly/monthly/annual/lifetime, real prices).
- `Unit.xcodeproj/.../Unit.xcscheme` — wire the config into the **Run** action only (Release/Archive ignore it).
- `docs/release-qa.md` — new §9 manual paywall/StoreKit walk.
- `docs/qa/*.png` — onboarding-start screenshots (committed, not left in /tmp).

## D) Screens inspected

- **iPhone 17 Pro (regular), runtime screenshot:** onboarding splash carousel — `docs/qa/onboarding-01-splash.png` ("Last time is already there"), `docs/qa/onboarding-02-carousel.png` ("Your numbers, from day one"). App launches clean, carousel auto-advances, "Set up your program" CTA pinned + reachable, no clipping.
- **All flow screens, static/architecture review:** splash, unit picker, import method, paste (+ empty/parse-failure states), library picker, schedule, program preview, paywall (loading / unavailable / loaded / error), legal footer.
- **Device-matrix gap:** no iPhone SE simulator installed (smallest is 390pt; SE is 375pt). `release-qa.md` §9 has the one-line `simctl create` to add it.

## E) Bugs found

**Founder manual QA (2026-07-02, iPhone 17, StoreKit config live):**
1. **Paywall scroll content collided with the status bar / Dynamic Island** — scrolled benefit
   rows rendered opaque under the clock. Root cause at the atom layer: `AppScreen` disabled the
   top scroll fade when the nav bar is hidden, and `PaywallView` is the app's only
   `hidesNavigationBar: true` screen. **Fixed:** `appScrollEdgeSoft(top: true)` unconditionally
   (`DesignSystem.swift`) — behavior-identical on every other screen (all evaluated true already).
2. **Reported: pinned CTA "overlays" the Lifetime card — NOT a bug.** The CTA is a VStack
   sibling *below* the ScrollView (`AppScreen.contentWithChrome`); content cannot render behind
   it. The faded card at the fold is the canonical bottom scroll fade; the founder's own
   scrolled screenshot shows Lifetime + disclosure + Restore/Terms/Privacy fully above the CTA.

Also aligned paywall benefit copy with the validated App Store language ("Log a set in
3 seconds", "Rest timer on your Lock Screen").

**Static audit:** no user-facing bugs. Only stale comments contradicting the current hard-paywall flow (design-system QA checklist item):
1. `OnboardingProgramPreviewView.swift` header — described a "Start your first workout" CTA; the CTA is "Choose a plan" and leads to the paywall.
2. `OnboardingViewModel.swift` header — referenced a non-existent "Create My Program" button.
3. `OnboardingProgramPreviewView.swift` — claimed the inline weight field shows a "—" prompt; `AppInlineWeightField` actually uses an empty placeholder (verified — so the banned-list dash-placeholder concern was a false alarm).

## F) Fixes applied

- The three stale comments above, corrected to match the shipped flow.
- (Paywall/StoreManager/DesignSystem improvements were already in the working tree; validated and kept.)
- No behavioral/redesign changes — the flow was already release-quality.

## G) StoreKit / paywall verification

- **Config:** `Unit/Unit.storekit` created with the four real product IDs and prices; wired to the scheme **Run** action only. JSON validated, scheme XML validated.
- **Products loaded?** Not machine-verified (simulator `simctl launch` does not inject the scheme's StoreKit config). Verified by code review: `StoreManager.loadProducts` fetches all four IDs, auto-selects first available; `PaywallView` derives every price from `Product.displayPrice` (no fake fallbacks).
- **Purchase / restore / unlock?** Not machine-verified (see §I). Code-verified: `purchase()` re-derives entitlement from `currentEntitlements` (never assumes success), `restore()` calls `AppStore.sync()` then re-checks + surfaces "No purchases to restore", the transaction listener finishes verified transactions and re-checks (handles refunds), and `ContentView` reactively swaps to the tabs on `store.isPurchased`. Non-dismissible (root swap, no close/secondary button).
- **Legal:** footer always renders Restore · Terms of Service · Privacy Policy; reachable by scroll even while the CTA is disabled.

## H) Build / test result

- `xcodebuild ... build` → **BUILD SUCCEEDED** (Debug, iOS Simulator; includes the uncommitted paywall changes).
- `xcodebuild ... test` (iPhone 17) → **TEST SUCCEEDED** (ProgramImporterTests, ProgramImportParserTests).
- `git diff --check` → **clean**.

## I) Remaining release blockers

Nothing code-level. Two runtime verifications remain, both covered by `release-qa.md` §9:
1. **Paywall layout on iPhone SE / regular / Pro Max (#6)** — architecture makes clipping unlikely (`AppScreen` scrolls the body, CTA is a pinned bar, tier prices use `minimumScaleFactor(0.6)`), but it is not screenshot-verified on three sizes. Walk §9.
2. **Purchase → unlock, and Restore (#8, #9)** — code-verified, not run. Walk §9 (⌘R with the wired config).

**Why not machine-driven:** the Simulator can be booted + screenshotted safely, but driving the multi-step SwiftUI flow to the paywall needs either synthetic global input (unsafe while the Mac is in active use) or a UI-test target (none exists; adding one is beyond a "fix clear bugs" pass). A UI-test + `SKTestSession` harness that automates the paywall + purchase across device sizes can be built as a follow-up if wanted.

---

## Addendum — 2026-07-11 submission-readiness pass

**Method advance:** the founder's iPhone 17 simulator holds a committed program, so its data
container (SwiftData store + UserDefaults) was copied into fresh installs on three sizes —
reaching the paywall by machine, no taps. This closes most of the §I gaps.

**Machine-verified this pass (screenshots in `docs/qa/`):**
- **Paywall layout on 3 sizes** — `paywall-se-unavailable.png` (SE 3rd gen, 375pt),
  `paywall-17-unavailable.png`, `paywall-promax-unavailable.png`. Header, benefits, recovery
  card, disclosure position, legal footer, pinned CTA: no clipping, nothing under the status
  bar, on all three. (State shown is products-unavailable — `simctl launch` doesn't attach the
  scheme's StoreKit config, which is itself the correct honest fallback.)
- **Products-unavailable state + recovery** — "Couldn't load subscriptions" card with Try again;
  CTA disabled with visible reason "Subscriptions couldn't load. Try again." No fake prices.
- **New benefit copy live** — "Log a set in 3 seconds" / "Rest timer on your Lock Screen" render
  in the shipped binary.
- **Pricing consistency** — pricing.md, decision-log 2026-07-02, `Unit.storekit`, and
  `StoreManager` all agree: $2.99/wk (default) · $4.99/mo · $29.99/yr · $44.99 lifetime; zero
  hardcoded prices in view code.
- **Build / tests / `git diff --check`** — all green on this pass.

**Founder-verified earlier (commit `7f7994a`, iPhone 17, Xcode run):** all four tiers load with
correct prices, Weekly pre-selected, CTA enabled — the loaded-products state works end-to-end.
That run predates the $2.99 change and the status-bar fade fix, which is why the PR #1 boxes
stay unchecked until the founder's re-walk.

**Fixed this pass:** `docs/archive/marketing/asc-submission.md` still said Weekly $4.99 in the
v2 IAP table and reviewer notes — corrected to $2.99, and a founder ASC checklist added.
`CURRENT_PROJECT_VERSION` bumped 14 → 15 per that doc's own pre-archive instruction.

**Still founder-only (cannot be machine-verified from the repo):**
1. Loaded-ladder walk at $2.99 on 3 sizes + purchase unlock + restore + post-unlock entry +
   Gym Test (⌘R with the StoreKit config — `release-qa.md` §9, ~10 min).
2. Everything in asc-submission.md §"v2 external gate — founder checklist" (Agreements/Tax/
   Banking for paid apps, subscription products at the locked prices, reviewer notes, archive
   build 15 + upload).

---

## Addendum — 2026-08-04 automated release gate

The July status above is retained as historical evidence, but its machine-verification gaps are
now closed. `UnitUITests/OnboardingPaywallFlowUITests.swift` contains twelve deterministic UI
tests covering the compact paste editor, onboarding-to-purchase-to-first-set journey, eligible
Monthly/Yearly/Weekly presentations, ineligible Weekly presentation, cancelled/unverified and
pending purchases, restore, existing subscription and Lifetime bypass, offline verified access,
product-load failure/retry/partial loading, and compact plus Accessibility Medium layouts.

All twelve paywall/onboarding UI tests passed on 2026-08-04 as part of the 14-test full UI suite
on **iPhone SE (3rd generation), iOS 27.0, 375 × 667**. The screenshots include the loaded tier
states, standard ineligible state, compact and Accessibility Medium feature-table layouts, and
the post-purchase Today/Programs surfaces. This supersedes the original “not machine-verified”
claim; it does not supersede Apple-controlled release gates.

The exact final code also passed **157 / 157 unit tests** on iPhone 17,
iOS 26.3.1, including the copied-version-2.1 migration, entitlement races,
duplicate-purchase prevention, introductory-offer presentation, and the full
starting-target/progression persistence contract. The final Release build for
Unit plus `UnitWidgetExtension` succeeded as **2.1 (65)**, and a clean iOS 26.3.1
Release launch produced no Unit-owned release-blocker log entries.

Still physical/external-only:

1. Confirm the exact submitted archive against App Store Connect products and a fresh Apple
   sandbox customer, including introductory-offer eligibility and Apple's purchase sheet.
2. Rewalk purchase, restore, cold relaunch, and one real-gym set on the connected iPhone.
3. Do not upload or submit from a dirty or diverged repository state.
