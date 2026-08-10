# Efe > Unit — ChatGPT Project replacement package

> **Approval required.** This package describes a destructive live Project replacement. Do not delete, upload, or edit anything in the live **Efe > Unit** ChatGPT Project until the user explicitly approves this exact package.

## Target

- Project: **Efe > Unit**
- Project ID: `g-p-69a18bf6b0ac81919e473e33ca454575`
- Mirror reviewed: 2026-08-10
- Canonical instruction text: `docs/custom-instructions.md`

## Source diff

Current mirror: **15 uploads**. Replacement: **7 uploads**.

| Current source | Replacement action |
|---|---|
| `DESIGN_SYSTEM.md` | Delete; upload current `DESIGN.md` |
| `product-compass.md` | Delete; upload current `docs/product-compass.md` |
| `goals.md` | Delete; upload current `docs/goals.md` |
| `CLAUDE.md` | Delete; do not re-upload |
| `behavior-change.md` | Delete; do not re-upload |
| `cognitive-principles.md` | Delete; do not re-upload |
| `mental-models.md` | Delete; do not re-upload |
| `UI Design Principles by Michael Filipiuk.pdf` | Delete; do not re-upload |
| `Shape Up Ship Work that Matters.pdf` | Delete; do not re-upload |
| `Practical UI Adham Dannaway.pdf` | Delete; do not re-upload |
| `100 Things Designers Need to Know.pdf` | Delete; do not re-upload |
| `Refactoring UI by Steve Schoger and Adam Wathan.pdf` | Delete; do not re-upload |
| `UX for Lean Startups by Laura Klein.pdf` | Delete; do not re-upload |
| `Atomic Design by Brad Frost.pdf` | Delete; do not re-upload |
| `Designing for Behavior Change.pdf` | Delete; do not re-upload |
| — | Upload current `PRODUCT.md` |
| — | Upload current `docs/AGENTS.md` |
| — | Upload current `docs/claude/scope.md` |
| — | Upload current `docs/pricing.md` |

The live instructions also require full replacement. They currently describe dark surfaces, the removed failure-driven progression model, and a stale source set. Replace them with the exact contents of `docs/custom-instructions.md` only after approval.

## Exact deletion manifest

Delete every current Project upload:

1. `DESIGN_SYSTEM.md`
2. `product-compass.md`
3. `goals.md`
4. `CLAUDE.md`
5. `behavior-change.md`
6. `cognitive-principles.md`
7. `mental-models.md`
8. `UI Design Principles by Michael Filipiuk.pdf`
9. `Shape Up Ship Work that Matters.pdf`
10. `Practical UI Adham Dannaway.pdf`
11. `100 Things Designers Need to Know.pdf`
12. `Refactoring UI by Steve Schoger and Adam Wathan.pdf`
13. `UX for Lean Startups by Laura Klein.pdf`
14. `Atomic Design by Brad Frost.pdf`
15. `Designing for Behavior Change.pdf`

## Exact upload manifest

After every deletion succeeds, upload only:

1. `PRODUCT.md`
2. `DESIGN.md`
3. `docs/AGENTS.md`
4. `docs/product-compass.md`
5. `docs/goals.md`
6. `docs/claude/scope.md`
7. `docs/pricing.md`

Do not upload `CLAUDE.md`, `docs/custom-instructions.md`, research PDFs, archives, audits, task summaries, or decision-log archaeology. Paste `docs/custom-instructions.md` into the Project Instructions field instead.

## Approved source fingerprints

These SHA-256 fingerprints bind this package to the reviewed local content:

| Local source | SHA-256 |
|---|---|
| `PRODUCT.md` | `adfeb296c0b9adca2d97da6fe6c38f0741ab47734183dfe590d73d8df12799e6` |
| `DESIGN.md` | `018ca00d8cd44063b23a1281f35615be8a99e1279be82f8bacdb963f1fa72ea2` |
| `docs/AGENTS.md` | `71b6bc37d8d25af60d3ed4b25706f59896c730b6ac8e9ef26c1e03018e261586` |
| `docs/product-compass.md` | `8a965fe961bb513b36e4fdf0e96c9ddfab811cd7d76b55ee995d2bb6bd1316d2` |
| `docs/goals.md` | `418eca10749ccc3a504905232cafabb5949b72114ffee41260ac0af578c6d3fa` |
| `docs/claude/scope.md` | `a2de50e1d0152fcd16554cef24774eb214446ff4bd750d752d8d1d44b202dae3` |
| `docs/pricing.md` | `62ce0541796569bbb223b060b6d1d4a25eb9357d918ba0f9182997944f323f45` |
| `docs/custom-instructions.md` | `bb02e89f8b6e96ea6099d8547884e6c1c5e799f51592fbf92e3acc0ccd2db3d6` |

Recompute these before applying the live replacement. If any fingerprint changes, stop and regenerate the package before asking for approval.

## Approval gate

Approval must cover all three actions together:

1. delete all 15 live uploads;
2. upload the seven canonical files above;
3. replace the live Project Instructions with `docs/custom-instructions.md`.

If the live source list changes before approval, stop, re-read it, and regenerate this manifest. Never partially apply an outdated manifest.
