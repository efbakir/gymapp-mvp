# Ready-made program matcher design scorecard

**Date**: 2026-08-12
**Mode**: contextual
**Status**: provisional
**Evidence**: iPhone 17e / iOS 26.3 renders at Large and Accessibility Medium, interaction walkthrough, screenshot hashes, banned-pattern check, and successful device-targeted build
**Anchors**: `docs/references/ios-screens/hevy__explore-programs.png` for readable program metadata and filters; existing Unit onboarding option cards for product fidelity

## Baseline

| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|
| System fidelity | 25% | 9 | Reuses `OnboardingShell`, `AppOptionTileCard`, `AppFilterChipBar`, `AppDropdownChip`, spacing tokens, and copy tokens. | No new component or one-off token required. | System | No rendered spacing comparison. |
| Product coherence and restraint | 20% | 9 | Two clear paths; matcher asks only questions the catalog can answer and explicitly says programs are ready-made matches. | Keep duration and equipment out until catalog metadata exists. | Product | Catalog quality still depends on editorial program review. |
| Craft | 20% | 7 | One question per screen, a best-match badge, secondary match reasons, and editable answer chips establish hierarchy. | Confirm long result names and two-line reasons on the smallest supported iPhone. | Verification | Code inspection cannot prove wrapping rhythm. |
| Gym Test and UX judgment | 25% | 8 | The setup flow stays outside active logging; selecting a program is reversible and requires an explicit `Review program` action. | Confirm answer-to-answer transitions and back behavior on a device. | Verification | Interaction timing was not rendered in this pass. |
| Accessibility and verification | 10% | 7 | Canonical controls supply 44 pt targets and text labels; selection is not conveyed by color alone. | Render at Accessibility Medium and verify result cards/chips do not clip. | Verification | VoiceOver order and Dynamic Type remain unrendered. |

**Weighted baseline**: 8.2/10

## Hard gates

| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|
| UI banned-list | PASS | Changed production UI files pass the repository hook. |
| Interactive targets ≥ 44 × 44 pt | PASS | Only canonical option cards, dropdown chips, and sticky CTA are interactive. |
| WCAG AA contrast | PASS | Existing Unit color tokens are reused without alteration. |
| Non-colour meaning and reduced motion | PASS | Selected cards retain textual/checkmark semantics; no new animation was added. |
| Gym Test | PASS | No active-workout logging surface was changed. |
| No dead or misleading affordance | PASS | Every answer advances, every result selects, and the CTA opens schedule review. |
| Distinct states are not byte-identical | PASS | Goal, normal results, and Accessibility Medium results have distinct SHA-256 hashes and fail byte-equality comparison as expected. |
| Light-only and portrait-only | PASS | Existing app constraints remain unchanged. |

## Priority fixes

1. No blocking visual fix remains from this pass. Keep the partially visible trailing filter chip as the horizontal-scroll cue at Accessibility sizes.

## Opportunity pass

- Do not add duration, equipment, generated-plan copy, or Supabase until the catalog and product model can support those promises honestly.

## Work completed

- Split onboarding into existing-program and ready-made-match paths.
- Added sequential goal, experience, and supported-days questions.
- Added ranked 1–3 result cards with transparent match reasons and editable answer chips.
- Added complete 2-day and 5-day catalog programs so every shown schedule has a real result.
- Carried controlled match buckets into the paywall and privacy-safe purchase telemetry.
- Rendered and exercised goal, experience, days, results, selected-result, and schedule-review states on iPhone 17e.
- Fixed the shared option-card badge hierarchy at every text size: `Best match` now sits above the title with an 8pt gap, leaving the full card width available to supporting copy while the selected checkmark remains top-right.
- Rechecked the experience and training-days sibling screens after the shared molecule fix.

## Carry forward

- The review remains contextual/provisional because no independent blind review was requested. The latest badge-placement adjustment was code-inspected and build-checked but not re-rendered; its final visual pass remains manual.
