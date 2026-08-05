---
name: page-audit
description: Audit and improve a Unit SwiftUI screen with the frozen Unit design-evaluation rubric. Use when a user asks to review, audit, check, fix, redesign, or polish a specific screen; shares a screenshot; says a page feels off or inconsistent; or requests a non-trivial single-screen UI change. Produces an evidence-backed scorecard, classifies fixes at atom/molecule/screen level, preserves one official baseline, and records only recurring lessons.
---

# Page audit

Evaluate one Unit screen against the product rules, design system, visual
references, and the frozen scorecard. Keep review evidence separate from builder
intent: judge what exists, not what the implementation meant to do.

## Required sources

Read in this order:

1. `CLAUDE.md` §1 and §§4–8
2. `docs/product-compass.md` pillars and current decision log
3. `DESIGN.md` and `Unit/UI/DesignSystem.swift`
4. `docs/atomic-design-system.md` and `docs/visual-language.md`
5. `docs/qa/design-evaluation/rubric.md` in full
6. `docs/qa/design-evaluation/lessons.md`
7. The closest anchor in `docs/references/ios-screens/` or
   `docs/references/details/`
8. The target view and directly used shared components

If no reference fits, name the gap. Do not invent a new visual language.

## Review mode

- Mark the review **blind** only if the reviewer did not build the work and did
  not see a prior score.
- Otherwise mark it **contextual**. Do not imply independence.
- Do not read previous numeric scores until the new baseline is recorded.
- Use independent critics only when the user explicitly requests a blind panel
  or delegated review. Keep each critic on one distinct lens and hide all prior
  scores.

## Process

### 1. Define the evidence

Resolve the screen file and available render or screenshot. Name the reference
anchor and the specific quality being borrowed. State which claims can and
cannot be verified from the evidence.

Do not start the simulator automatically. `ui-visual-verify` remains
user-invoked only. Without current visual evidence, the score is provisional and
the rubric's evidence caps apply.

### 2. Run static gates

Check the target and changed shared code for:

- Raw colours, fonts, spacing, radii, dividers, or banned glyphs
- Non-canonical cards, buttons, lists, bars, fades, sheets, or toolbar chrome
- New feature-local views/modifiers that duplicate an existing primitive
- Dark-mode or landscape assumptions
- “0 kg”, ambiguous placeholders, dead actions, and test scaffolding
- Touch-target code that cannot reach 44×44 pt

Use `.claude/hooks/ui-banned-list.sh` as the mechanical source of truth. Do not
weaken it to make a build pass.

### 3. Score the frozen dimensions

Score system fidelity, product coherence and restraint, craft, Gym Test and UX
judgment, and accessibility and verification using
`docs/qa/design-evaluation/rubric.md`.

For each dimension return:

- Integer score
- Evidence for what works
- Defects with exact fixes and fix layer
- One blind spot: what this pass may have missed

Compute one weighted baseline. Do not round individual dimensions and do not
inflate the baseline after applying fixes.

### 4. Evaluate hard gates

Mark every rubric gate PASS, FAIL, or UNVERIFIED. Any FAIL blocks the screen.
Any UNVERIFIED keeps the scorecard provisional.

### 5. Classify the fix level

Ask whether sibling screens would retain the same defect after a local patch.

- **Atom**: fix a token in `DesignSystem.swift`.
- **Molecule/organism**: fix the canonical shared component.
- **Screen**: fix composition unique to this screen. Use last.

Run `component-reuse-check` before introducing a new SwiftUI view, modifier, or
variant.

### 6. Close the loop

For build/fix/polish requests, apply cheap high-impact fixes at the correct
layer, then re-check static gates. Keep the original baseline and list the work
completed separately. For review-only requests, report findings without editing.

Do not invoke simulator verification unless the user explicitly asks. When they
do, use `ui-visual-verify`, re-check affected states, and compare states that
should differ for byte-identical output.

### 7. Remember without bloating

For build/change tasks, save the scorecard as
`docs/qa/design-evaluation/scorecards/YYYY-MM-DD-<screen>.md`. Update
`lessons.md` only for a confirmed recurrence or a newly discovered evaluator
blind spot. Do not promote a one-off finding into permanent rules.

For review-only tasks, return the scorecard in chat unless the user asks for a
file.

## Scorecard format

```markdown
# [Screen] design scorecard

**Date**: YYYY-MM-DD
**Mode**: blind | contextual
**Status**: official | provisional
**Evidence**: [render/screenshot paths or “code only”]
**Anchor**: [reference and borrowed qualities]

## Baseline
| Dimension | Weight | Score | Evidence | Top defect + exact fix | Fix layer | Blind spot |
|---|---:|---:|---|---|---|---|

**Weighted baseline**: X.X/10

## Hard gates
| Gate | PASS / FAIL / UNVERIFIED | Evidence |
|---|---|---|

## Priority fixes
1. [Highest-impact fix]

## Opportunity pass
- [0–3 conformant ways to raise the ceiling; not included in the score]

## Work completed
- [Fixes applied after the baseline, or “Review only”]

## Carry forward
- [Unresolved issue, owner/layer, next check]
```

## Boundaries

- Do not audit business logic beyond what affects the screen's user experience.
- Do not claim visual verification from code.
- Do not score accessibility or interaction as passed without relevant evidence.
- Do not create a new design-system primitive without explicit user approval.
