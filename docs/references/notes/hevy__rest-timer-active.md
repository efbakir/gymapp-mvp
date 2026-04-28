---
anchor: docs/references/ios-screens/hevy__rest-timer-active.png
---

# hevy__rest-timer-active

Hevy mid-workout with `Rest Timer: 1min 5s` running on the Warm Up exercise. Useful only as a **timer-label format** anchor — Unit's `RestTimerControl` already covers the affordance.

**Borrow:**
- **Humanized timer label format** (`1min 5s`, not `1:05`). Unit currently uses `m:ss` format in `timerDisplayText` (e.g. `1:05`, `0:30`). Hevy's spelled-out format is more legible at a glance and harder to misread under fatigue. Worth considering as an alternative for `RestTimerControl`'s label — but only if the format also handles the `0:30` start state (`30s`?) without churn.
- The **clock icon prefix** on the timer chip — it makes the chip readable as "this is a timer" without reading the label. SF Symbol `clock` or `timer.circle`. Unit's RestTimerControl could prefix similarly.

**Do NOT borrow:**
- ❌ **Timer-as-label-only chrome.** Hevy hides the +/- adjust and the play/pause behind a tap on the chip; the chip is just a label inline. Unit's `RestTimerControl` explicitly exposes decrease / toggle / increase as visible controls. Per the §1 north star (≤ 3 seconds per set under fatigue), one-tap-to-adjust beats two-tap-to-adjust. Unit's choice wins.
- ❌ **iOS-blue tint** on the chip and label.
- ❌ The placement of the chip *inside the exercise card chrome* — only relevant if Unit ever adopts the row-list paradigm (it shouldn't, see `hevy__active-workout.md`).
