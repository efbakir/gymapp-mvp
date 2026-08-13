# Black branded splash opener design scorecard

**Date**: 2026-08-12
**Mode**: contextual
**Status**: provisional
**Evidence**: changed SwiftUI code; no post-change simulator render
**Anchor**: existing Unit app icon and onboarding opener composition

## Baseline

| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|
| System fidelity | 25% | 7 | Existing splash composition and semantic tokens are retained. | Apply the black surface only to the transient opener. | Screen | No rendered safe-area evidence. |
| Product coherence and restraint | 20% | 7 | The two-second opener is already separate from the value carousel. | Use the progression tagline without comma punctuation. | Copy | Handoff tone is unrendered. |
| Craft | 20% | 6 | Logo, title, and tagline already have a restrained hierarchy. | Switch title and dismiss chrome to high-contrast foreground tokens. | Screen | Logo contrast was not measured from a render. |
| Gym Test and UX judgment | 25% | 7 | The opener adds no tap and auto-advances after two seconds. | Keep the carousel and setup flow light and interactive. | Screen | Transition timing was not exercised. |
| Accessibility and verification | 10% | 6 | Reduced Motion behavior and Dynamic Type remain intact. | Use dark system chrome only while the black opener is mounted. | Screen | Status-bar appearance remains visually unverified. |

**Weighted baseline**: 6.7/10

## Hard gates

| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|
| UI banned-list | PASS | Changed feature code passes the repository hook; the appearance exception is recorded in the decision log. |
| Interactive targets ≥ 44 × 44 pt | PASS | The optional dismiss target remains 44 × 44 pt. |
| WCAG AA contrast | UNVERIFIED | High-contrast semantic tokens are used, but no rendered measurement was taken. |
| Non-colour meaning and reduced motion | PASS | No meaning depends on colour; existing reduced-motion handling remains. |
| Gym Test | PASS | Active workout UI is unchanged. |
| No dead or misleading affordance | PASS | The opener remains non-interactive and auto-advances. |
| Distinct states are not byte-identical | UNVERIFIED | No post-change screenshots were captured. |
| Light-only and portrait-only | PASS | The recorded exception ends when the two-second opener unmounts; the carousel and product remain light and portrait-only. |

## Priority fixes

1. Restrict the black surface and white system chrome to the two-second opener.
2. Remove the comma from `Progressive overload made simple.`

## Opportunity pass

- None. The opener should stay brief and undecorated.

## Work completed

- Added the token-based black opener surface.
- Updated title, tagline, dismiss button, and status-bar contrast.
- Kept the rest of onboarding in Unit's light appearance.

## Carry forward

- Visually inspect the first frame and the black-to-light handoff when simulator access is explicitly requested.
