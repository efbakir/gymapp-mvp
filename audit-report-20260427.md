# MVP UI Cleanup Audit Report — 2026-04-27

## Scope
System-consistency pass across the five major screens: Today, Programs, History, Settings, and Active Workout. Goal: remove unnecessary custom controls, align to native iOS patterns where appropriate, and eliminate design-system drift.

## Docs Consulted
- `CLAUDE.md` §4–§8 (scope fence, design system rules, simplification bias)
- `docs/product-compass.md` (north star, MVP boundary)
- `docs/goals.md` (v1 scope boundaries)
- `docs/atomic-design-system.md` (token layers, banned patterns)
- `docs/visual-language.md` (color, typography, card, icon rules)
- `docs/design-principles.md` (Gym Test, consistency)
- `Unit/UI/DesignSystem.swift` (canonical atoms, molecules, organisms)

## Findings

### Already correct (no changes needed)
- All screens use `AppScreen` wrapper
- All cards use `AppCard` / `appCardStyle()`
- All CTAs use `AppPrimaryButton`
- Native `NavigationStack` + `TabView` throughout
- Touch targets ≥ 44pt
- SF Symbols only, no raw hex/padding/radius in feature views
- No chevron.right/forward as disclosure
- Light mode correct, portrait-only
- No banned patterns (dark-mode-first, hex literals, etc.)

### Issues fixed

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | `HistoryView.swift` | Custom `AppSegmentedControl` for List/Calendar mode toggle — redundant since native `UISegmentedControl` appearance is already configured in `ContentView` | Replaced with native `Picker(.segmented)` |
| 2 | `SettingsView.swift` | Custom `AppSegmentedControl` for kg/lb weight unit toggle | Replaced with native `Picker(.segmented)` |
| 3 | `DesignSystem.swift` | `AppSegmentedControl` component — reimplements native iOS segmented control with custom pill animation; no callers remain after migration | Removed (simplification per §8) |
| 4 | `TemplatesView.swift` | "Add Day" button used `AppSecondaryButton(tone: .accentSoft)` — banned as "Add X" trigger per §5 | Replaced with `AppGhostButton("Add Day")` |
| 5 | `TodayView.swift` | `TodayWorkoutDetailsSheet` used `ProductTopBar` inside `NavigationStack` — every other sheet uses native toolbar; this was the only inconsistency | Replaced with native `.navigationTitle` + `.toolbar` + `.appNavigationBarChrome()` |

## Files changed
- `Unit/Features/History/HistoryView.swift` — native Picker replaces custom segmented control
- `Unit/Features/Settings/SettingsView.swift` — native Picker replaces custom segmented control
- `Unit/Features/Today/TodayView.swift` — workout details sheet uses native toolbar
- `Unit/Features/Templates/TemplatesView.swift` — ghost button for Add Day
- `Unit/UI/DesignSystem.swift` — removed `AppSegmentedControl` (~80 lines)

## Components replaced with native controls
- `AppSegmentedControl` → `Picker(.segmented)` (2 call sites)

## Shared components reused
- `AppGhostButton` (replaced `AppSecondaryButton` misuse)
- Native `NavigationStack` toolbar (replaced `ProductTopBar` in sheet)

## Intentionally left alone
- **CalendarTabView**: Exists as a standalone file but isn't in the tab bar. Not removing (may be planned for future use).
- **`appToolbarTextStyle()`**: Applies `.weight(.semibold)` to toolbar text buttons. While the banned list mentions this, the exception clause ("unless every toolbar in the app uses the same weight") applies — it's used consistently app-wide.
- **`ProductTopBar` definition** in DesignSystem.swift: Still used by other screens outside the five major views; only removed its usage from feature sheets where native toolbar is correct.
- **TrainingWeekProgress** / `TodayWeekOverviewSheet`: Already uses native `Picker(.segmented)` — no changes needed.
- **Active Workout warmup chevron.up/down**: Standard expand/collapse pattern, not banned (only chevron.right/forward is banned).

## Not added (MVP scope fence)
- No social, discovery, AI plans, videos, or non-MVP extras
- No ProgressionEngine, 8-week cycles, target-vs-actual UI (banned per §4)
- No new components or design system growth
