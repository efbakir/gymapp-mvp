---
anchor: docs/references/ios-screens/hevy__exercise-picker.png
---

# hevy__exercise-picker

Closest direct competitor reference for Unit's **Exercise Library / picker** surface. Hevy is light-mode here, which is unusual for them — useful.

**Borrow:**
- Leading icon + two-line row: icon → exercise name (primary) → muscle group (secondary, smaller, lighter weight). This is the canonical row for Unit's exercise picker.
- Top chrome: search field via `.searchable` (system), then a horizontal pill row for filters ("All Equipment", "All Muscles") — maps to `AppFilterChip`.
- Sticky bottom CTA `Add N exercises` that updates with selection count. Use `AppPrimaryButton` in a fixed footer; combine with `appScrollEdgeSoft(top: false, bottom: true)` so the list fades behind it.
- Section header `Recent Exercises` above the recents block, then `All Exercises` below.

**Do NOT borrow:**
- The leading **blue accent stripe** on recent rows. Unit doesn't tint rows by state. Use `cardRowFill` if any background is needed; otherwise a plain row.
- The trailing **chart icon** that looks chevron-like. Unit's banned-list explicitly forbids `chevron.right` / `chevron.forward`. If we need a trailing affordance, use a small icon button or nothing.
- `Cancel` / `Create` top-toolbar pair. Unit uses `AppScreen` chrome + system toolbar weight (no `.semibold`).
- The system iOS blue tint on the CTA. Unit accent is `0x0A0A0A`.
