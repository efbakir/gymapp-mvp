# Full Component Audit & Bug-Fix Plan

## Context
The app has grown through rapid MVP iteration. Components work but have accumulated inconsistencies: hardcoded values bypassing design tokens, duplicate patterns, missing states, undersized tap targets, and dead code. This pass fixes bugs at the component level first, then propagates to screens.

---

## Fixes — grouped by priority

### BLOCKING

| # | Component / Screen | Issue | Fix |
|---|---|---|---|
| B1 | `TrainingWeekProgress.swift:389-395` | `dayStatusIcon` uses raw `.font(.system(size:20))` — bypasses design tokens | Replace with `AppIcon` images using `.image(size:20, weight:.semibold)` like the `.completed` case already does |
| B2 | `TemplateDetailView.swift:155-159` | Delete-exercise button is 32×32pt — below 44pt minimum | Expand `.frame(width:44, height:44)`, keep visual circle at 32pt via inner content |
| B3 | `HistoryView.swift:684` | Calendar day cells are 32×32pt — below 44pt tap target | Add `.contentShape(Rectangle())` with `.frame(minWidth:44, minHeight:44)` around the button content |

### IMPORTANT

| # | Component / Screen | Issue | Fix |
|---|---|---|---|
| I1 | `DesignSystem.swift:1580` | `WorkoutCommandCard` uses hardcoded `.padding(.bottom, 18)` — not a token | Replace with `.padding(.bottom, AppSpacing.md)` (16pt, closest token) |
| I2 | `DesignSystem.swift:918-920` | `SetProgressIndicator.borderColor()` always returns `.clear` — dead code + invisible stroke at line 871 | Remove the `borderColor` function and the `.stroke(borderColor(...))` overlay |
| I3 | `SessionDetailView.swift:63-72` | Empty `AppCard` rendered when `exerciseSnapshots` is empty | Wrap in `if !exerciseSnapshots.isEmpty` |
| I4 | `CyclesView.swift:335` | `ProjectedWeekSheet` uses `.presentationDetents([.medium])` — can't expand to see all targets | Change to `.presentationDetents([.medium, .large])` |
| I5 | `TodayView.swift` toolbar (line ~140) | Calendar icon button has no accessibility label | Add `.accessibilityLabel("History")` |
| I6 | `TemplatesView.swift` toolbar (line ~47) | Settings icon button has no accessibility label | Add `.accessibilityLabel("Settings")` |

### POLISH

| # | Component / Screen | Issue | Fix |
|---|---|---|---|
| P1 | `DesignSystem.swift:502` | `AppTag` vertical padding uses hardcoded `6` | Replace with `AppSpacing.xs + 2` or define as `AppSpacing.tagVertical` — simplest: use `AppSpacing.sm` (8pt) for consistency |
| P2 | `OnboardingBaselinesView.swift:83,90,96` | Hardcoded `.tracking(1.0)` on 3 labels | Extract to `AppFont` constant (e.g. `AppFont.uppercaseLabelTracking`) |
| P3 | `OnboardingSplitBuilderView.swift:124` | Hardcoded `.tracking(1.0)` | Same fix as P2 — use shared tracking constant |
| P4 | `PaywallView.swift:29` | Hardcoded `.kerning(0.6)` | Use a named `AppFont` tracking constant |
| P5 | `DesignSystem.swift:1074-1100` | `ExercisePreviewItem` uses `AppColor.disabledSurface` for regular (non-disabled) detail text | Replace with `AppColor.textSecondary` |

---

## Files to modify

1. **`Unit/UI/DesignSystem.swift`** — I1 (hardcoded padding), I2 (dead borderColor), P1 (tag padding), P5 (color misuse), add `uppercaseLabelTracking` constant to `AppFont`
2. **`Unit/Features/Today/TrainingWeekProgress.swift`** — B1 (system font → AppIcon)
3. **`Unit/Features/Templates/TemplateDetailView.swift`** — B2 (tap target)
4. **`Unit/Features/History/HistoryView.swift`** — B3 (calendar tap target)
5. **`Unit/Features/History/SessionDetailView.swift`** — I3 (empty state guard)
6. **`Unit/Features/Cycles/CyclesView.swift`** — I4 (sheet detents)
7. **`Unit/Features/Today/TodayView.swift`** — I5 (a11y label)
8. **`Unit/Features/Templates/TemplatesView.swift`** — I6 (a11y label)
9. **`Unit/Features/Onboarding/OnboardingBaselinesView.swift`** — P2 (tracking)
10. **`Unit/Features/Onboarding/OnboardingSplitBuilderView.swift`** — P3 (tracking)
11. **`Unit/Features/Subscription/PaywallView.swift`** — P4 (kerning)

## Verification

- `xcodebuild` clean build with iPhone 17 Pro simulator
- Grep for remaining `.font(.system(` in Features/ — should be zero
- Grep for remaining hardcoded tracking/kerning — should be zero except intentional cases
- Grep for `borderColor` in SetProgressIndicator — should be gone
