---
anchor: docs/references/ios-screens/alma__home.png
---

# alma__home

Mostly an **anti-pattern reference**. Useful for one specific thing — the rest violates Unit's rules.

**Borrow:**
- Card stack rhythm at the top: a single hero metric card (Alma Score), then a contextual coaching/tip card, then a denser metrics tile. Three cards, three densities — same idea Unit uses for Today.
- The way the hero card has a small `i` info button in the top-right — a low-friction affordance to surface explanation without taking layout space. Unit could borrow this *placement*, but the icon should be a tap target, not an iOS-blue circle.
- Macros tile pattern: one parent card containing four mini-tiles (Calories / Protein / Carbs / Fat) with icon + value + label. Maps directly to a workout-summary tile if Unit ever needs one (PRs / volume / duration / sets).

**Do NOT borrow:**
- ❌ The central **custom Floating Action Button** (the green `+` overlapping the tab bar). **Banned by CLAUDE.md §5** (parallel-implementation + simplification bias). Add affordances in Unit live in toolbar items or `AppCardListAddRow` — never as a floating button. If you ever feel tempted, run `/component-reuse-check` first; the answer will be "use the existing toolbar / list-add row".
- The **green/orange/yellow accent palette** and the per-metric color tinting on the macro tiles. Unit accent is `0x0A0A0A` (darkest black). Tiles are monochrome.
- The carousel **pagination dots** under the hero card. Unit doesn't ship horizontal carousels; stack the cards vertically.
- The custom tab-bar treatment with the FAB cutting through it. Unit uses the iOS-native `TabView`, undecorated.
