# Unit — Design system entrypoint

This file exists to give tooling (and agents) a stable design system entrypoint.

## Source of truth docs

- `docs/atomic-design-system.md` — atomic layers, tokens, banned patterns, and where components live in the repo
- `docs/visual-language.md` — visual hierarchy, light-first surfaces, Gym Test UI rules, and copy tone
- `docs/design-principles.md` — product-level principles that shape UI decisions (minimalism, clarity, speed, accessibility, token discipline)

## Code source of truth

- `Unit/UI/DesignSystem.swift` — implementation of tokens and shared UI primitives used across screens

## External design references

- **Programs — active program main card** (day strip, typography, list chrome): [Paper — Gymapp / templates (programs)](https://app.paper.design/file/01KMMP9CFH5MC6Z40BSFS4D1MF?page=01KMQC759AVTDCWGXG7A27DTCG&node=2FN-0)
- **Today — hero card exercise preview list** (list fill, row type colors, spacing): [Paper — Gymapp / today (homepage)](https://app.paper.design/file/01KMMP9CFH5MC6Z40BSFS4D1MF?page=01KMQC759AVTDCWGXG7A27DTCG&node=2P6-0)
- **Today — “Day n of m” chip** (20pt height, 8px horizontal inset): [Paper — node 2P1-0](https://app.paper.design/file/01KMMP9CFH5MC6Z40BSFS4D1MF?page=01KMQC759AVTDCWGXG7A27DTCG&node=2P1-0) — implemented as `AppTag` `.compactCapsule`; height matches `WeeklyProgressStepper` / `AppProgressChipMetrics.rowHeight`.

