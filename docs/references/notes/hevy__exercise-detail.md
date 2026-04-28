---
anchor: docs/references/ios-screens/hevy__exercise-detail.png
---

# hevy__exercise-detail

Pattern reference for an exercise's **history detail view** — chart + metric switcher + section rhythm.

**Borrow:**
- Header rhythm: exercise name (large, primary) → primary muscle (one line, secondary) → secondary muscles (one line, even more muted). Three weights, three densities — hierarchy is legible without color.
- Inline "insight" card below the title (icon + headline like *"How to log barbell exercises"*). Useful as a tooltip pattern for Unit's first-time states (e.g. ghost-value explainer the first time it pre-fills).
- Chart treatment: y-axis labels right-aligned, sparse x-axis date labels, single-line chart with end markers. Use this as the chart anchor when Unit ever ships per-exercise history.
- Pattern of `100 kg · Aug 19` inline above the chart — current value + date. Clean way to state "your last set" without a card.

**Do NOT borrow:**
- The **iOS-blue tint everywhere** (header underline, axis dots, chart line). Unit's accent is `0x0A0A0A` — chart line should be darkest black or a single neutral.
- The **bottom-floating segmented CTAs** (`Heaviest Weight | One Rep Max | Best Set`). They read as a parallel control to the toolbar and overlap with the tab bar. Unit uses `AppSegmentedControl` placed inline in the screen body, not floating.
- The lightbulb-tip card style. Unit doesn't have an equivalent atom — design decision deferred. If we ever need it, route through `/component-reuse-check` first.
- `Summary | History | How to | Leaderboard` tab strip with underline indicator. Unit's history surface uses a system segmented control, not a custom underlined tab strip. No "Leaderboard" — out of scope (no social).
