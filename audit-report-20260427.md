# Unit MVP UI Cleanup — Audit Report

**Date:** 2026-04-27

---

## Files Changed

| File | Action | Description |
|------|--------|-------------|
| `Unit/Features/History/CalendarTabView.swift` | **Deleted** | Dead code — calendar already integrated in HistoryView via segmented picker |
| `Unit.xcodeproj/project.pbxproj` | Modified | Removed CalendarTabView references from Xcode project |
| `Unit/UI/DesignSystem.swift` | Modified | Removed 7 unused components, cleaned dead parameters |
| `Unit/Features/Templates/TemplateDetailView.swift` | Modified | Replaced custom Circle toolbar button with native text button |
| `Unit/Features/Templates/TemplatesView.swift` | Modified | Aligned "Edit program" button with AppSecondaryButton pattern |
| `Unit/Features/History/HistoryView.swift` | Modified | Replaced text-based month nav with icon buttons |

---

## Components Removed (dead code)

| Component | Reason |
|-----------|--------|
| `CalendarTabView` | Full file — not referenced by any navigation or tab |
| `AppTabHeader` | Banned pattern per atomic-design-system.md; replaced by ProductTopBar |
| `UnitTabBar` | Unused — app uses native TabView |
| `UnitTabItem` | Unused — only referenced by UnitTabBar |
| `DayCard` | Unused in any feature view |
| `ExerciseRow` | Never instantiated anywhere |
| `IconSquareButton` | Never used in any feature view |
| `MetricDisplay` | Never used; dead `metricStyle` reference in ExerciseCommandCard cleaned |
| `AppShadow` | Never used in any feature or design system component |

## Dead Parameters Removed

| Parameter | Location | Reason |
|-----------|----------|--------|
| `usesCircularTrailingButton` | `AppScreen` | Stored but never read in view body |
| `metricStyle` | `ExerciseCommandCard` | Stored but never passed to WorkoutCommandCard |

---

## Components Replaced with Native Controls

| Before | After | Screen |
|--------|-------|--------|
| Custom Circle + border icon button (edit/done) | Native text toolbar button ("Edit"/"Done") | TemplateDetailView |
| Text buttons ("Back"/"Next") for month nav | Icon buttons (arrow.left / arrow.right) | HistoryView calendar |

---

## Shared Components Reused (verified in use)

- `AppScreen` — all 5 major screens + detail views
- `AppCard` / `appCardStyle()` — all card surfaces
- `AppPrimaryButton` / `AppSecondaryButton` — CTAs
- `AppListRow` — row patterns
- `AppDivider` — separators
- `AppTag` — status badges
- `ProductTopBar` — product headers
- `SettingsSection` — settings groups
- Native `Picker(.segmented)` — History mode toggle, weight unit toggle
- Native `NavigationStack` / `toolbar` — all screens
- Native `TabView` — root navigation

---

## Bugs Fixed

- Xcode project references to deleted CalendarTabView removed (would cause build warning)
- Dead `metricStyle: MetricDisplay.Style` parameter removed from ExerciseCommandCard (would fail to compile after MetricDisplay removal)

---

## Intentionally Left Unchanged

| Item | Reason |
|------|--------|
| `SessionDetailView.swift` | Unreachable but functional; may be wired up later |
| `WeeklyProgressStepper` | Documented product primitive in atomic-design-system.md |
| `HeroWorkoutCard` | Documented organism; uses WeeklyProgressStepper |
| `AppStepper` | Documented product primitive for workout logging |
| `AppNavBar` / `AppNavBarWithTextTrailing` | Used internally by AppScreen |
| `navigationBarTitleDisplayMode` on AppScreen | Passed by SessionDetailView and PRLibraryView; harmless |
| Onboarding / Paywall / Cycles views | Out of scope for this MVP cleanup pass |
| Custom Inter font usage | Deliberate product choice per visual-language.md |
