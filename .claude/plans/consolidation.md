# Design System Consolidation Plan

## 1. Add `EmptyStateCard` to DesignSystem.swift

Consolidates `NoProgramCard` and `SetupIncompleteCard` from TodayView.swift — they're structurally identical (eyebrow + productHeading title + productAction message + CTA button, all centered).

```swift
struct EmptyStateCard: View {
    let eyebrow: String
    let title: String
    let message: String
    let buttonLabel: String
    let action: () -> Void
}
```

**Files changed:**
- `Unit/UI/DesignSystem.swift` — add `EmptyStateCard`
- `Unit/Features/Today/TodayView.swift` — delete `NoProgramCard` and `SetupIncompleteCard` structs, replace usages with `EmptyStateCard`

## 2. Add `AppDividedList` to DesignSystem.swift

Consolidates the repeated `VStack(spacing:0) + ForEach + conditional AppDivider()` pattern found in 6+ places.

```swift
struct AppDividedList<Data, ID, RowContent>: View
    where Data: RandomAccessCollection, ID: Hashable, RowContent: View
```

Takes a data collection, id keypath, and row builder. Automatically inserts `AppDivider()` between rows.

**Apply to these sites:**
- `TodayView.swift` → `TodayWorkoutDetailsSheet` exercise list (lines ~336-352)
- `SessionDetailView.swift` → exercise snapshots list (lines ~64-75)
- `HistoryView.swift` → `SessionSummaryCard` exercise list (lines ~828-839)
- `TemplatesView.swift` → inactive splits list (lines ~109-124)
- `ExerciseProgressView.swift` → session points list (lines ~163-172)

Sites with unique divider styling (leading-only padding in TrainingWeekProgress, after-every-item in CyclesView) will be left as-is since they don't match the standard pattern.

## 3. Build & verify

Run `xcodebuild` to confirm no regressions.
