# Onboarding carousel copy design scorecard

**Date**: 2026-08-12
**Mode**: contextual
**Status**: provisional
**Evidence**: user-provided copy specification and code inspection; no current simulator render
**Anchor**: `docs/references/ios-screens/bevel__onboarding-fitness.png` — concise headline/body hierarchy around one primary onboarding action

## Baseline

| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|
| System fidelity | 25% | 8 | Existing carousel, typography, spacing, artwork, CTA, and disclosure are reused unchanged. | No copy-specific system defect. | Screen | No current rendered comparison. |
| Product coherence and restraint | 20% | 8 | Three slides tell one sequence: next lift, reps then weight, one-tap logging. | Replace abstract range language with the requested concrete example. | Screen copy | `5 lb` is an example before unit selection and may be read literally by kilogram users. |
| Craft | 20% | 7 | Copy is short, sentence-cased, direct, and avoids hype. | Confirm line wrapping on the smallest supported iPhone. | Verification | Code inspection cannot prove visual rhythm. |
| Gym Test and UX judgment | 25% | 8 | No interaction, navigation, active logging, or CTA behavior changes. | None in this scope. | — | No interaction run in this pass. |
| Accessibility and verification | 10% | 6 | Existing scalable text layout remains; focused UI assertions cover the exact strings. | Run the existing compact and Accessibility Medium carousel tests when simulator verification is requested. | Verification | No current VoiceOver or Dynamic Type render. |

**Weighted baseline**: 7.6/10

## Hard gates

| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|
| UI banned-list | PASS | The copy-only production edit introduces no UI pattern or token changes. |
| Interactive targets ≥ 44 × 44 pt | UNVERIFIED | Interaction code is unchanged; not measured in this turn. |
| WCAG AA contrast | PASS | Existing `AppColor.textPrimary` and `AppColor.textSecondary` usage is unchanged. |
| Non-colour meaning and reduced motion | PASS | Meaning remains textual; motion behavior is untouched. |
| Gym Test | PASS | Active workout logging code is untouched. |
| No dead or misleading affordance | PASS | No affordance was added or changed. |
| Distinct states are not byte-identical | UNVERIFIED | No screenshots were captured in this turn. |
| Light-only and portrait-only | PASS | Appearance and orientation code are untouched. |

## Priority fixes

1. Apply the requested title and three body-copy values exactly and lock them with focused UI assertions.

## Opportunity pass

- None. The requested tightening is appropriately restrained.

## Work completed

- Updated the first title to `Know what to lift next`.
- Updated all three body lines exactly as specified.
- Added exact-copy assertions to the existing compact carousel UI test.

## Carry forward

- Visual verification remains pending by project rule; inspect compact and Accessibility Medium wrapping when the user next requests simulator verification.
