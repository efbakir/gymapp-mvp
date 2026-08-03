# Final submit checklist — Unit v2.1 (build 60)

> The ASC handoff package. Everything below is paste-exact for App Store Connect; nothing requires a code change.
> Updated 2026-08-03 for the progressive-overload pivot. Companions: `docs/pricing.md` (pricing truth) and `docs/release-qa.md` (device gauntlet).

---

## 0. Warnings — read before touching ASC

- **The trial must be real.** Configure a seven-day free introductory offer on Weekly, Monthly, and Yearly in the `unit-pro` group before submitting. Lifetime has no trial.
- **Do not rename early.** The selected build and first screenshot must contain the tested progression recommendation flow before `Unit: Progressive Overload` is submitted.
- **No fake prices.** Every visible in-app price is StoreKit-derived. ASC product config is the only place prices exist.
- **The app UI is English-only.** Do not claim or imply localization anywhere. Localized *metadata* is a separate, optional step (§8).
- **Product IDs are immutable.** If any ASC screen asks you to create a product, you are on the wrong screen.

## 1. Version / build

| Field | Value | Verified |
|---|---|---|
| Marketing version | **2.1** | `MARKETING_VERSION = 2.1` in all 8 pbxproj configs |
| Build | **60** | `CURRENT_PROJECT_VERSION = 60` in all 8 pbxproj configs |
| Archive source | tagged `main` | clean tree, local `main` equals `origin/main`, tag `v2.1-build60` points at the archived commit |

## 2. App name

Paste **`Unit: Progressive Overload`** exactly from **`docs/app-store-copy.md` §App name** only after the progression gate passes. Home-screen icon stays `Unit` (`INFOPLIST_KEY_CFBundleDisplayName`).

## 3. Subscription products (must match exactly)

Group: reference name `unit-pro`, display name `Unit Pro`.

| Product | Product ID | Type | Price (USD base) |
|---|---|---|---|
| Weekly — **default selection** | `com.unit.weekly` | Auto-renewable, 1 week | **$2.99** |
| Monthly | `com.unit.monthly` | Auto-renewable, 1 month | **$4.99** |
| Yearly | `com.unit.annual` | Auto-renewable, 1 year | **$29.99** |
| Lifetime (optional) | `com.unit.lifetime` | Non-consumable | **$44.99** |

- [ ] Confirm Weekly reads **$2.99** in ASC (the 2026-07-02 change). If it reads $4.99, fix before anything else.
- [ ] All prices automatically generated from the USD base — no custom storefront prices.
- [ ] Weekly, Monthly, and Yearly each show a **7-day free** introductory offer; all remain in the same `unit-pro` subscription group.
- [ ] Confirm an eligible sandbox account sees the trial and an ineligible account does not.
- [ ] Lifetime has no introductory offer.
- [ ] Lifetime: only if the non-consumable is already configured. Do not create it for this submission.

## 4. Reviewer notes

Paste verbatim from **`docs/app-store-copy.md` §Reviewer notes** into App Review Information → Notes. ($2.99 Weekly price is correct there.)

## 5. English metadata

Paste every field verbatim from **`docs/app-store-copy.md`** — subtitle, promotional text, description, keywords, What's New. That file is the single copy source; this checklist deliberately embeds no strings so they can't drift.

The description's paid-purchase paragraph and the two legal URLs are Guideline 3.1.2(b) compliance — never trim them.

## 6. Screenshot set

- [ ] Replace screenshot 1 with the real next-workout recommendation state described in `docs/app-store-copy.md`.
- [ ] Keep the strongest existing speed, import, history/privacy, and Lock Screen timer screenshots after it.
- [ ] Confirm every screenshot is captured from build 60 and contains no claim the build cannot perform.

## 7. IAP / subscription attachment checklist

- [ ] Business → Agreements: **Paid Applications agreement active** (not "Pending"). Blocks everything if not.
- [ ] Features → Subscriptions → `unit-pro` group exists with the 3 auto-renewables (§3 IDs and prices exact).
- [ ] Each product has an English display name + description and a **review screenshot** (one capture of `PaywallView` covers all).
- [ ] App Store tab → version 2.1 → In-App Purchases and Subscriptions → **attach Weekly, Monthly, Yearly** (+ Lifetime if configured).
- [ ] Build 60 attached to the version.

## 8. Localization

- [ ] Do not paste the existing de-DE, es-MX, pt-BR, fr-FR, or tr files. They are stale after the progression/trial pivot.
- [ ] If 2.1 is localized, regenerate each locale from the new English source, run the validator, and complete linguistic QA before paste; otherwise ship English-only.

## 9. Privacy / age rating / URLs

- [ ] App Privacy: **"Data Not Collected"** (matches `Unit/PrivacyInfo.xcprivacy` — UserDefaults only, reason CA92.1).
- [ ] Age rating: **4+** (all questionnaire categories None/No).
- [ ] Encryption: **No** (`ITSAppUsesNonExemptEncryption = false` in Info.plist).
- [ ] Privacy Policy URL: `https://unitlift.app/privacy` — returns 200.
- [ ] Support URL: `https://unitlift.app/support` — returns 200.
- [ ] Marketing URL: `https://unitlift.app` — returns 200.
- [ ] Copyright: `2026 Efe Bakir`.
- [ ] First-person check on any copy you edited: no `we / us / our`.

## 10. Pre-archive gate (before Product → Archive)

- [ ] StoreKit sandbox QA — every step in `docs/pricing.md` §StoreKit sandbox verification checklist, on this exact build, with sandbox Apple IDs.
- [ ] `docs/release-qa.md` gauntlet run on device.
- [ ] Xcode Settings shows **Version 2.1 (60)**.
- [ ] `git status --short` is empty and local `main` equals `origin/main`.
- [ ] Tag `v2.1-build60` points at the exact commit being archived.
- [ ] Archive from clean tagged `main` only.
- [ ] Known site inconsistency (not an archive blocker, fix before marketing push): `app/(marketing)/compare/data.ts` still says "Core logging is free forever. Pro is $4.99/mo or $29.99/yr." in 3 rows, and `app/(marketing)/page.tsx` has one "Free. No account. No ads." eyebrow. Both contradict the hard paywall on the live site.
