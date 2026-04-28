---
anchor: docs/references/ios-screens/future__workout-consistency.png
---

# future__workout-consistency

Calendar-grid bottom sheet showing daily workout circles by week. Direct anchor for any **history calendar / streak surface** Unit ships — relevant since `CalendarTabView.swift` was deleted (see `gitStatus`) and the pattern may return in a simplified form.

**Borrow:**
- **One row per week, 7 circles per row, day-of-week labels under each circle.** Date number inside the circle. This is the canonical week-grid layout. Maps to `LazyVGrid(columns: 7)` or a horizontal `HStack` per week.
- **Section headers between week groups** (`Sep 16-22`, `Sep 23-29`, `Last Week`, `This Week`). Date-range labels are clearer than week-numbers; "Last Week" / "This Week" relative labels for the most recent groups read better than dates. Unit should mirror this relative-vs-absolute split.
- **Bottom-sheet chrome**: `OVERVIEW` centered uppercase header + `Done` dismiss top-right + grab handle. Matches Unit's `appBottomSheetChrome`. Confirms the convention.
- **Empty-day treatment**: gray-stroke empty circle with no fill, day-of-week label muted underneath. No additional per-day copy. Quiet by default.
- **Section title outside the card surface**: `Workout Consistency` (large, primary) + `0 WORKOUT DAYS` (small, muted, uppercase) — title + supporting line *above* the calendar grid, not inside it. Maps to `AppSectionHeader` placement.

**Do NOT borrow:**
- ❌ **Blue fill** on this-week circles. Unit accent is `0x0A0A0A`. The "today / completed" affordance should be a thin black stroke or a subtle filled circle in `AppColor.cardRowFill` — never a tint.
- ❌ **`0 Days` count on the right of each week section.** Adds visual noise; the empty circles already communicate the same thing. Simplification bias prefers cutting it.
- ❌ **`0 WORKOUT DAYS` hero count** at the top when empty. Discouraging copy on an empty state. Unit's empty-state convention is to show progress potential, not a zero.
- ❌ The **`OVERVIEW` uppercase tracking** as a sheet header — Unit's sheet headers use `AppFont.productAction` title-case ("Overview"), not letterspaced caps.
