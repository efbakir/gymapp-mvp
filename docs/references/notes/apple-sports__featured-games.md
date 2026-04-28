---
anchor: docs/references/ios-screens/apple-sports__featured-games.png
---

# apple-sports__featured-games

> ⚠️ **DARK MODE.** Unit is light-mode only (CLAUDE.md §5). This reference is kept for **structure and rhythm only** — ignore every color, gradient, and contrast decision in this image. If we ever want a definitive light-mode anchor for the same pattern, recapture from a light-mode app.

**Borrow:**
- The single-card-multiple-rows pattern: one outer card groups several game rows separated by internal dividers. This is **exactly** the `AppCardList` molecule. The visual proof that this is the right primitive for grouped data lives here.
- Tabular score alignment in a row: `[team logo] [team name]` left, `[score]` aligned to a column edge, `[status text]` centered. Unit uses this rhythm any time we show paired numbers (e.g. weight × reps with a target column).
- Section header above the card (`Featured Games`) — small, centered, lower weight than the body. Maps to `AppSectionHeader` placement.
- Consistent vertical row height across all rows in the card — no dynamic height per row. Unit's set rows should follow the same rule.

**Do NOT borrow:**
- The dark gradient background. Unit is paper-cream / off-white. All color decisions must be re-derived in light mode.
- The greens/blues/oranges in the score numbers. Unit uses tabular numerals in `0x0A0A0A` only.
- The hero `Get Started` pill button on top. Unit's primary CTA is full-width `AppPrimaryButton`, not a centered pill.
- The horizontal **league avatar row** at the top of the screen. Unit doesn't have a horizontal-scroll category navigator on the home surface — banned by simplification bias and the parallel-implementation rule.
