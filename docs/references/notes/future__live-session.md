---
anchor: docs/references/ios-screens/future__live-session.png
---

# future__live-session

The **closest commercial anchor for Unit's `WorkoutCommandCard`** — single-card command panel with one hero metric, supporting metric pairs, one primary action. This is the taste reference the WorkoutCommandCard hierarchy was missing.

**Borrow:**
- **Single primary metric + two supporting metric pairs + one primary CTA.** Future shows ELAPSED → MILES (hero) → PACE / PROJ SPLIT → AVG PACE / BEST SPLIT → status + End. Unit's WorkoutCommandCard mirrors the exact same hierarchy: progress steps → metric value (hero) → primary "Complete set" → rest-timer row. The validated pattern is: **one hero, two supporting pairs max, one primary action, sticky status row at the bottom**. Anything more is noise.
- **Numeric typography weight contrast.** The `0.66` (MILES, hero) is rendered in a much *lighter* weight than the smaller secondary numbers — Future uses light/thin for hero numerals, leaving them feeling spacious. Unit's `numericDisplay` is `weight: .bold` — worth experimenting with `.regular` or `.medium` for the metric hero to match this feel of generous, calm primacy. The bold-everywhere convention currently risks the hero feeling small relative to its visual weight.
- **Label-above-value rhythm**: `ELAPSED` (small uppercase muted) → `25:11.68` (large value). Unit already does this in `WorkoutCommandCard`'s metric supporting text — confirms the convention.
- **Sticky bottom row pairing status + primary action** (`Running` + `End ✓`). Maps directly to `SessionStateBar`. The checkmark icon in the End button is a nice touch — completes the affordance verb. Unit's "Finish workout" CTA could adopt the trailing checkmark.
- **Light, paper-cream background**, not pure white. Future uses a subtle gradient top → cream bottom. Unit's `AppColor.background` already lands in this territory — confirms the choice.

**Do NOT borrow:**
- ❌ **The teal accent on `25:11.68`** (and the green `End ✓` button). Unit accent is `0x0A0A0A`. Re-derive in monochrome.
- ❌ **Pagination dots** indicating swipeable metric pages. Unit's WorkoutCommandCard is one card, not a pager. Out of scope.
- ❌ **Heart-rate display** `♥ 105` and the **avatar bottom-right** — out of scope (no HR tracking, no social).
- ❌ **Compact circular toolbar buttons** (the white-filled music + pause circles top of screen). Visually charming, but CLAUDE.md §5 says "prefer iOS-native over custom" for toolbar chrome. This is a deliberate non-borrow — `tide__focus-summary` shows the same idiom and the same conclusion stands.
- ❌ **The split / projection pair** as a concept — irrelevant to gym logging. Borrow the *layout* of two-by-two metric pairs, not the metric semantics.
