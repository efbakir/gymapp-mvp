---
anchor: docs/references/ios-screens/hevy__rest-timer-picker.png
---

# hevy__rest-timer-picker

Bottom sheet over the active-workout screen for picking a rest-timer duration. Anchor for **time-picker sheet chrome** — useful if Unit ever ships a "set custom rest" affordance.

**Borrow:**
- **Half-height bottom sheet** (`presentationDetents([.height(...)])`) — not full-height. The picker doesn't need the full screen. Matches `appBottomSheetChrome` convention.
- **Header rhythm**: `Rest Timer` title centered + `Warm Up` subtitle (muted) immediately below — communicates *what* and *for which exercise* in two short lines. Maps to a small `VStack(spacing: AppSpacing.xs)` at the sheet top.
- **Wheel picker** for time selection (`off`, `5s`, `10s`, …) — system iOS `Picker(...) .pickerStyle(.wheel)`. Unit currently uses `+/- 30s` step buttons; the wheel is the right choice when the user wants to pick a *value* rather than nudge the current one.
- **Sticky bottom CTA `Done`** — commits the selection. Unit's equivalent is `AppPrimaryButton` at the bottom of the sheet content (no `.sheet { ScrollView { … } }` per CLAUDE.md §5 sheet rule).

**Do NOT borrow:**
- ❌ **iOS-blue `Done` CTA.** Use `AppPrimaryButton` (`0x0A0A0A`).
- ❌ The **settings cog top-right** of the sheet — unclear affordance, low information scent. Unit prefers no top-right action on a picker sheet, or if there must be one, an explicit verb (`Reset`, `Default`).
- ❌ **The dimmed backdrop** style is iOS-native here, but capture this as the *expected* sheet behavior — don't borrow Hevy's specific dim opacity, just confirm Unit's `presentationBackground` and detents are doing the same job.
