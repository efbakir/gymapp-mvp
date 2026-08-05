# Final submit checklist — Unit v2.1 (build 66)

> The ASC handoff package. Copy fields are paste-exact; the introductory offers require the founder actions in §4 before submission.
> Updated 2026-08-04 for the progression-guided v2.1 release. Companions: `docs/pricing.md` (pricing truth) and `docs/release-qa.md` (device gauntlet).

---

## 0. Warnings — read before touching ASC

- **Trial is not release-ready yet.** The app supports a seven-day offer, but App Store Connect must carry the matching Monthly and Yearly offers and an Apple sandbox purchase sheet must confirm the free period before submission.
- **No permanent free tier.** Unit remains a hard paywall after onboarding. Weekly and Lifetime have no introductory offer.
- **No fake prices.** Every visible in-app price is StoreKit-derived. ASC product config is the only place prices exist.
- **The app UI is English-only.** Do not claim or imply localization anywhere. Localized *metadata* is a separate, optional step (§8).
- **Product IDs are immutable.** If any ASC screen asks you to create a product, you are on the wrong screen.

## 1. Version / build

| Field | Value | Verified |
|---|---|---|
| Marketing version | **2.1** | `MARKETING_VERSION = 2.1` in all 8 pbxproj configs |
| Build | **66** | `CURRENT_PROJECT_VERSION = 66` in all 8 pbxproj configs |
| Archive source | tagged `main` | clean tree, local `main` equals `origin/main`, tag `v2.1-build66` points at the archived commit |

## 2. App name

Paste **`Unit: Progressive Overload`** exactly from **`docs/app-store-copy.md` §App name**. Home-screen icon stays `Unit` (`INFOPLIST_KEY_CFBundleDisplayName`).

## 3. Subscription products (must match exactly)

Group: reference name `unit-pro`, display name `Unit Pro`.

| Product | Product ID | Type | Price (USD base) |
|---|---|---|---|
| Weekly — **ineligible default** | `com.unit.weekly` | Auto-renewable, 1 week | **$2.99** |
| Monthly — **eligible default** | `com.unit.monthly` | Auto-renewable, 1 month | **$4.99** |
| Yearly | `com.unit.annual` | Auto-renewable, 1 year | **$29.99** |
| Lifetime (optional) | `com.unit.lifetime` | Non-consumable | **$44.99** |

- [ ] Confirm Weekly reads **$2.99** in ASC (the 2026-07-02 change). If it reads $4.99, fix before anything else.
- [ ] All prices automatically generated from the USD base — no custom storefront prices.
- [ ] Monthly and Yearly each have the one-week Free introductory offer described in §4.
- [ ] Weekly and Lifetime have no introductory offer.
- [ ] Lifetime: only if the non-consumable is already configured. Do not create it for this submission.

## 4. Introductory-offer setup — founder action

- [ ] Open Features → Subscriptions → the Unit subscription group in App Store Connect.
- [ ] Open Monthly (`com.unit.monthly`) and add a **one-week Free** introductory offer.
- [ ] Open Yearly (`com.unit.annual`) and add a **one-week Free** introductory offer.
- [ ] Apply both offers to the intended storefronts and launch dates.
- [ ] Confirm Weekly (`com.unit.weekly`) has no introductory offer.
- [ ] Confirm Lifetime (`com.unit.lifetime`) has no introductory offer.
- [ ] Wait for the StoreKit sandbox configuration to propagate.
- [ ] Test with a fresh sandbox customer who has never redeemed an introductory offer in this subscription group.
- [ ] Confirm Apple's purchase sheet itself displays the seven-day free period and correct post-trial price for Monthly, then repeat the sheet check for Yearly with another fresh eligible sandbox customer if needed.

Apple allows one introductory-offer redemption per customer per subscription group. Do not expect one customer to redeem both the Monthly and Yearly trials. See Apple's [StoreKit implementation guide](https://developer.apple.com/documentation/storekit/implementing-introductory-offers-in-your-app) and [App Store Connect setup guide](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-introductory-offers-for-auto-renewable-subscriptions/).

## 5. Reviewer notes

Paste verbatim from **`docs/app-store-copy.md` §Reviewer notes** into App Review Information → Notes. ($2.99 Weekly price is correct there.)

## 6. English metadata

Paste every field verbatim from **`docs/app-store-copy.md`** — subtitle, promotional text, description, keywords, What's New. That file is the single copy source; this checklist deliberately embeds no strings so they can't drift.

The description's paid-purchase paragraph and the two legal URLs are Guideline 3.1.2(b) compliance — never trim them.

## 7. Screenshot set

- [ ] Upload the new English progression screenshot set defined in `docs/app-store-copy.md`.
- [ ] Confirm the first screenshot proves the new progressive-overload promise.
- [ ] Do not use screenshots from the Progression QA harness.

## 8. IAP / subscription attachment checklist

- [ ] Business → Agreements: **Paid Applications agreement active** (not "Pending"). Blocks everything if not.
- [ ] Features → Subscriptions → `unit-pro` group exists with the 3 auto-renewables (§3 IDs and prices exact) and the §4 offers.
- [ ] Each product has an English display name + description and a **review screenshot** (one capture of `PaywallView` covers all).
- [ ] App Store tab → version 2.1 → In-App Purchases and Subscriptions → **attach Weekly, Monthly, Yearly** (+ Lifetime if configured).
- [ ] Build 66 attached to the version.

## 9. Localization

- [ ] Ship 2.1 English-only.
- [ ] Do not paste or publish de-DE, es-MX, pt-BR, fr-FR, or tr. All five files are explicitly stale after the beginner-inclusive English rewrite.

## 10. Privacy / age rating / URLs

- [ ] App Privacy: declare **Product Interaction** and **Purchase History** for analytics; both are not linked to identity and not used for tracking. Do not declare workout content.
- [ ] TelemetryDeck app identifier is supplied through the private `TELEMETRYDECK_APP_ID` build setting and verified in the archive; it is not committed to source.
- [ ] Settings → Anonymous analytics disables future events immediately.
- [ ] Age rating: **4+** (all questionnaire categories None/No).
- [ ] Encryption: **No** (`ITSAppUsesNonExemptEncryption = false` in Info.plist).
- [ ] Privacy Policy URL: `https://unitlift.app/privacy` — returns 200.
- [ ] Support URL: `https://unitlift.app/support` — returns 200.
- [ ] Marketing URL: `https://unitlift.app` — returns 200.
- [ ] Copyright: `2026 Efe Bakir`.
- [ ] First-person check on any copy you edited: no `we / us / our`.

## 11. Pre-archive gate (before Product → Archive)

- [ ] StoreKit sandbox QA — every step in `docs/pricing.md` §StoreKit sandbox verification checklist, on this exact build, with sandbox Apple IDs.
- [ ] Apple's purchase sheet confirms the seven-day free period and correct renewal price for Monthly and Yearly; do not infer this from the in-app paywall alone.
- [ ] `docs/release-qa.md` gauntlet run on device.
- [ ] Xcode Settings shows **Version 2.1 (66)**.
- [ ] `git status --short` is empty and local `main` equals `origin/main`.
- [ ] Tag `v2.1-build66` points at the exact commit being archived.
- [ ] Archive from clean tagged `main` only.
- [ ] Marketing-site pricing and privacy copy matches the hard paywall, conditional seven-day offer, and anonymous-analytics disclosure in this build.
