# System-wide Impeccable pass — 2026-08-12

## Scope

Applied the five requested Impeccable workflows—critique, distill, layout,
typeset, and polish—to every live public marketing route and the active iOS
feature surface.

- Marketing: home, compare pages, program pages, support, privacy, terms, and
  updates, plus the shared header and footer.
- iOS: Today, active workout, programs/templates, history, settings,
  onboarding, and subscription screens.
- Excluded: API routes and the internal `/figma` and `/docs` utilities, because
  they are not live customer-facing pages.

The pass ran in a single context because the user explicitly requested
uninterrupted autonomous completion without questions or delegation.

## Baseline

| Surface | Score | P1 findings | Assessment |
|---|---:|---:|---|
| Live marketing site | 29/40 | 1 | Strong identity with a loading defect and repetitive page grammar. |
| Active iOS features | 36/40 | 0 | Stable, restrained, and already aligned with the shared design system. |

Archived baselines:

- `.impeccable/critique/2026-08-12T14-45-41Z__app-marketing.md`
- `.impeccable/critique/2026-08-12T14-45-41Z__unit-features.md`

Post-remediation marketing score: **37/40**, with no P0–P2 finding. Snapshot:
`.impeccable/critique/2026-08-12T14-53-53Z__app-marketing.md`.

## Decisions

### Preserve the native app core

The iOS app already uses `AppColor`, `AppFont`, `AppSpacing`, `AppRadius`, and
the canonical reusable components. A broad rewrite would add release risk
without solving a verified problem, especially in the under-three-second
logging flow. No new SwiftUI component or token was introduced.

### Replace repeated marketing scaffolding with editorial rhythm

The main four-part product story now uses alternating full-width rows. The six
supporting features use compact divided rows with contained product visuals.
This removes ten equal-weight rounded cards and makes the page hierarchy easier
to scan.

### Reserve mono uppercase labels for metadata

Section introductions, navigation, and footer headings now use sentence-case
Geist. The `.eyebrow` style remains available only for genuine state, dates,
and compact data labels.

### Set a 16px narrative floor on the web

Support, comparison tables, FAQs, legal prose, program pages, and product copy
now use a 16px minimum. Smaller sizes remain only for true metadata and compact
visual labels. The responsive marketing type ramp is documented in `DESIGN.md`.

### Show local marketing images immediately

`MarketingPhoto` no longer hides an available local asset until React receives
an `onLoad` event. Cached images therefore cannot remain stuck behind a
placeholder. The fallback appears only after a real load error.

### Keep mobile trust and proof compact

The trust statements stack cleanly on phones without a stranded separator.
App Store reviews are now simple divided quotes instead of tall cards with
forced empty space. Audience items use an orderly responsive grid.

## Verification

- `npm run typecheck` — passed.
- `npm run lint` — passed.
- `npm run build` — passed; the local build reports the expected missing Vercel
  Blob token for live release-note syncing, but still generated all 27 pages.
- `npm test` — passed, 7 files and 43 tests.
- iOS simulator Debug build with code signing disabled — passed.
- Impeccable deterministic scan of live marketing code — zero findings after
  the documented type-ramp update.
- Unit UI banned-pattern hook — passed.
- Browser review at 390px and 1280px — no horizontal page overflow on home,
  compare, program, support, privacy, terms, or updates.
- Visual review confirmed the hero photograph loads, the responsive trust band
  is intact, and the new showcase/supporting-feature layouts preserve hierarchy.

## Release review

Before an iOS release, continue the existing device-level checks for compact
iPhones, Dynamic Type, purchase restoration, and paywall safe-area clearance.
This pass deliberately did not alter the stable native screen architecture.
