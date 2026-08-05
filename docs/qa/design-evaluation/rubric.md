# Unit design evaluation rubric

This is the frozen ruler for Unit screen reviews. Change it only when user
feedback exposes a blind spot or a product decision changes the bar. Do not
rewrite it between reviews.

## Evidence and review status

- **Blind**: an independent reviewer did not build the screen and did not see a
  prior score.
- **Contextual**: the reviewer shares build context. Useful, but not blind.
- **Official**: the screen has current visual evidence, every applicable hard
  gate was checked, and the score came from a blind review.
- **Provisional**: any other review. Never chart it as the official trend.

Do not read a previous numeric score before grading the current screen. Compare
scores only after the new baseline is recorded.

## Calibration anchors

Use integers from 0–10 for each dimension.

| Score | Meaning |
|---|---|
| 0–4 | Broken, off-system, or blocks the core task. |
| 5 | Works, but feels generic, incomplete, or poorly judged. |
| 6 | Credible at a glance; meaningful defects or missing verification remain. |
| 7 | Solid implementation with visible or evidenced polish gaps. |
| 8 | Verified and polished; only minor, non-blocking issues remain. |
| 9 | Survives a senior product-design critique with no material change. |
| 10 | Rare, reference-quality work with no meaningful defect found. |

“Looks good” is 6, not 9. A dimension cannot score 8+ unless the relevant
result was rendered, measured, or exercised. Code inspection alone caps craft,
UX, and accessibility at 7.

## Weighted dimensions

| Dimension | Weight | What to judge |
|---|---:|---|
| System fidelity | 25% | Tokens, canonical components, reference fidelity, light-only and portrait-only rules, no parallel implementation. |
| Product coherence and restraint | 20% | One intentional Unit product; numerics-first hierarchy; one clear action; no template feel, clutter, or decorative fitness UI. |
| Craft | 20% | Spacing rhythm, alignment, typography, states, copy precision, pressed feedback, and deliberate small details. |
| Gym Test and UX judgment | 25% | One-handed use under fatigue, ≤3 seconds per set, ≤2 taps to first logged set, state clarity, recovery, and no dead affordances. |
| Accessibility and verification | 10% | 44×44 pt targets, WCAG AA contrast, non-colour cues, Dynamic Type resilience, reduced motion, and proof that each relevant state rendered. |

Weighted total:

`system × .25 + coherence × .20 + craft × .20 + UX × .25 + accessibility × .10`

Round once to one decimal place. The three design-judgment dimensions—coherence,
craft, and UX—carry most of the score on purpose.

## Hard gates

Any failed gate blocks a passing verdict regardless of the weighted score.

1. The existing UI banned-list hook passes for changed Swift files.
2. Every interactive target is at least 44×44 pt.
3. Text meets WCAG AA contrast: 4.5:1 for body text, 3:1 for large text.
4. No meaning relies on colour alone; reduced motion is honoured.
5. The hot logging path still passes the Gym Test.
6. No dead, misleading, or decorative affordance appears tappable.
7. No two states that should differ render byte-identically.
8. Unit remains light-only and portrait-only.

If a gate was not checked, mark it **UNVERIFIED**, not passed. A scorecard with
an unverified gate is provisional.

## Opportunity pass

After defects are scored, name up to three ways the design could become more
distinctive using existing Unit primitives. Do not add those ideas to the
official score and do not invent new components by default. Safe restraint is
better than decorative novelty, but a clean generic screen is not a 9.

## Fix and memory discipline

- Preserve deviations from a reference that are intentional UX improvements.
- Apply cheap, high-impact fixes first, then re-check affected gates.
- Keep the original baseline. Post-fix work is progress, not a new official
  score unless a new blind review is run.
- Keep one-off findings in the scorecard.
- Add a miss to `lessons.md` only when it recurs or exposes a rubric blind spot.
- Promote a recurring judgment miss to the narrowest existing source-of-truth
  document as one general rule.
- Move a recurring mechanical miss into a hook, test, token, or component, then
  remove the prose rule it replaced.

