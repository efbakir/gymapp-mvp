# Onboarding splash disclosure design scorecard

**Date**: 2026-08-12
**Mode**: contextual
**Status**: provisional
**Evidence**: code only; supplied simulator screenshot was unavailable
**Anchor**: `docs/references/ios-screens/bevel__onboarding-fitness.png` — focused onboarding hierarchy with one primary action

## Baseline

| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|
| System fidelity | 25% | 8 | Existing tokens and canonical primary button | Duplicate disclosure competed with the CTA; remove it | Screen | Current render unavailable |
| Product coherence and restraint | 20% | 6 | One clear setup action | Purchase warning appeared before the purchase decision; retain it only on paywall | Screen | Carousel pacing not exercised |
| Craft | 20% | 7 | Consistent spacing and type tokens | Extra caption weakened bottom hierarchy; remove it | Screen | Small-device layout not rendered |
| Gym Test and UX judgment | 25% | 8 | CTA remains direct and reachable | Redundant copy added reading cost; remove it | Screen | Hit testing not exercised |
| Accessibility and verification | 10% | 6 | Canonical button preserves 44pt target | Update UI test contract; visual and Dynamic Type states remain unverified | Screen/test | VoiceOver not exercised |

**Weighted baseline**: 7.2/10

## Hard gates

| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|
| Existing UI banned-list | PASS | No new banned pattern introduced |
| Interactive targets at least 44pt | PASS | Canonical `AppPrimaryButton`; UI assertion retained |
| WCAG AA contrast | UNVERIFIED | No current render |
| Non-colour cues and reduced motion | PASS | Change removes static copy only |
| Gym Test | PASS | Active logging path untouched |
| No dead or misleading affordance | PASS | Setup CTA remains the sole action |
| Distinct states render differently | UNVERIFIED | No simulator run |
| Light-only and portrait-only | PASS | No appearance or orientation change |

## Priority fixes

1. Remove the early paid-plan sentence and keep required subscription disclosures on the paywall.

## Opportunity pass

- None; removal is the intended improvement.

## Work completed

- Removed the paid-plan sentence below the onboarding CTA.
- Removed its copy constant and obsolete UI-test expectations.
- Confirmed paywall disclosure uses `AppFont.muted` and `AppColor.textSecondary`.

## Carry forward

- Visual and Dynamic Type verification remain pending.
