# Program matcher question navigation design scorecard

**Date**: 2026-08-12
**Mode**: contextual
**Status**: provisional
**Evidence**: supplied goal-question screenshot plus changed SwiftUI code; no post-change render
**Anchor**: `docs/references/ios-screens/bevel__onboarding-fitness.png` for a compact progress cue, strong single action, and restrained onboarding hierarchy

## Baseline

| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|
| System fidelity | 25% | 7 | The screen already used `OnboardingShell` and `AppOptionTileCard`. | Extend the existing progress and segmented-control molecules instead of adding feature-local variants. | Molecule | The supplied screenshot shows only the goal state. |
| Product coherence and restraint | 20% | 7 | One question and three direct answers keep the task focused. | Expose the three nested questions without changing the outer five-step model. | Screen + molecule | The complete match sequence was not rendered in this pass. |
| Craft | 20% | 6 | Typography and card rhythm match the surrounding onboarding flow. | Replace the repeated day cards with the canonical compact segmented control and add a quiet nested progress track. | Molecule + screen | Compact-width and Dynamic Type wrapping remain unrendered. |
| Gym Test and UX judgment | 25% | 5 | First-time taps advanced quickly. | Preserve answers on Back, show their selected state, and provide Continue for deliberate revisiting. | Screen state | The revised tap timing was not exercised. |
| Accessibility and verification | 10% | 6 | Canonical option cards provide large targets and selected accessibility traits. | Add the same selected trait to segmented items and combine outer and nested progress labels. | Molecule | VoiceOver order and post-change selection announcement remain unverified. |

**Weighted baseline**: 6.2/10

## Hard gates

| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|
| UI banned-list | PASS | Changed feature files pass `.claude/hooks/ui-banned-list.sh`; visual values remain in `DesignSystem.swift`. |
| Interactive targets ≥ 44 × 44 pt | PASS | `AppOptionTileCard`, `AppSegmentedControl`, and the shell CTA retain their canonical target floors. |
| WCAG AA contrast | PASS | Existing Unit semantic color tokens are reused without modification. |
| Non-colour meaning and reduced motion | UNVERIFIED | Selected accessibility traits and reduced-motion-aware progress animation exist in code; the post-change states were not rendered. |
| Gym Test | PASS | No active-workout logging surface changed. |
| No dead or misleading affordance | UNVERIFIED | State handling and CTA actions parse successfully but were not exercised in the app. |
| Distinct states are not byte-identical | UNVERIFIED | No post-change screenshots were captured. |
| Light-only and portrait-only | PASS | The change adds no appearance or orientation override. |

## Priority fixes

1. Preserve each prior answer while Back changes only the visible sub-question.
2. Show nested question progress and an explicit Continue action on revisited questions.
3. Use the canonical segmented control for the five supported day counts.

## Opportunity pass

- Keep the progress treatment quiet; the question title and sticky CTA should remain dominant.

## Work completed

- Added explicit goal, experience, days, and results navigation without clearing saved answers.
- Kept first-time selection auto-advance while revisited questions use the sticky Continue CTA.
- Added selected-state accessibility to the shared segmented control, including an unanswered state.
- Added nested question progress to the shared onboarding progress molecule.
- Added UI-test coverage for Back, retained selection, and Continue across all three questions.

## Carry forward

- Visually inspect goal, experience, days, and results at the smallest supported portrait size and one accessibility text size.
