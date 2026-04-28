---
anchor: docs/references/ios-screens/bevel__home.png
---

# bevel__home

Useful as a **summary surface** anchor — a date-stamped home that groups three high-level metrics and a contextual insight. Closest in spirit to what Unit's Today view aspires to.

**Borrow:**
- Top of screen: date selector + `Active` status pill on the left, a small contextual chip on the right (here: weather). Unit's equivalent: date + last workout name. Two pills max.
- A **three-tile horizontal row** of summary metrics (Strain / Recovery / Sleep) — single card containing three internal tiles, each with a label, a percentage, and a small visual. Unit could mirror this with three workout-summary metrics (e.g. Volume / Sets / Duration) on the History or Today surface.
- The **inline insight card** below the tile row (icon + headline + 2-line body, with an expand affordance in the top-right). This is the right pattern for PR notifications post-workout: contextual, dismissible, non-modal.
- Section header → tile row → insight card → next section. Clean vertical rhythm. Lots of breathing room. Maps to `AppScreen` + `AppSectionHeader` + `AppCard` stacking.

**Do NOT borrow:**
- The **colored progress rings** (orange Strain, green Recovery, blue Sleep). Per-metric color tinting violates Unit's monochrome accent rule. If we ever ship a ring, it's a single neutral on cream.
- The **bottom green FAB** (`+` button cutting through the tab bar). Same banned pattern as `alma__home` — see CLAUDE.md §5 parallel-implementation rule. Add actions live in the toolbar or `AppCardListAddRow`.
- The custom tab bar with the FAB notch. Use iOS-native `TabView`.
- `30°C East Jakarta` weather pill is irrelevant to Unit and should not be replicated as a "context chip" without a real reason — borrow the *placement* if needed, not the content.
- The "Steady Indoor Walk" insight card has an emoji 🚶 prefixed inline. Unit doesn't ship emoji in body copy — use `AppIconCircle` or a system SF Symbol instead.
