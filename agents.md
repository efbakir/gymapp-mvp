# Unit — Agent Guidance

This file orients AI agents (e.g. Claude Code, Cursor) working on the Unit codebase.

## What this project is

Unit is a **zero-friction gym logging tool** for iOS. The primary program unit is the **Template** — a lightweight repeatable routine. The core UI paradigm is **ghost values** — the app pre-fills weight and reps from the last session so the user can log a set with a single tap.

The **Gym Test** applies: logging a set (weight, reps) in **under 3 seconds** under physical stress. The `ProgressionEngine` (auto-increment, cycles) is **deferred to post-v1**; it exists in code for data compatibility but is not user-facing in the template-based flow.

## Tech stack

- **Swift 6** (concurrency-safe), **SwiftUI** (NavigationStack), **SwiftData** (local-first, CloudKit-ready later).
- **iOS 18+** (Live Activities for rest timer).
- **Charts framework** (Swift Charts — no third-party charting).

## Where to look

| Topic | Location |
|-------|----------|
| Design principles | `docs/design-principles.md` |
| Atomic design system (layers, tokens, banned patterns) | `docs/atomic-design-system.md` |
| Visual language (light-first, hierarchy, Gym Test) | `docs/visual-language.md` |
| Product compass (decisions, positioning archaeology) | `docs/product-compass.md` |
| Product manifesto | `docs/PRODUCT_MANIFESTO.md` |
| App positioning | `docs/APP_POSITIONING.md` |
| Use cases | `docs/USE_CASES.md` |
| Apple HIG reference | `docs/apple-hig.md` |
| Competitors | `docs/competitors.md`, `docs/competitors-analysis.md` |
| Cognitive / behavior / mental models | `docs/cognitive-principles.md`, `docs/behavior-change.md`, `docs/mental-models.md` |
| Values and goals | `docs/values.md`, `docs/goals.md` |
| GPT/AI custom instructions (UX/product execution) | `docs/custom-instructions.md` |

## Project structure

| Folder | Contents |
|--------|----------|
| `Unit/Models/` | SwiftData models: Split, Exercise, DayTemplate, WorkoutSession, SetEntry, Cycle, ProgressionRule |
| `Unit/Engine/` | `ProgressionEngine.swift` — pure functional progression logic (deferred to post-v1) |
| `Unit/Features/Today/` | TodayView (template dashboard), ActiveWorkoutView (command-panel logging, rest timer) |
| `Unit/Features/Templates/` | TemplatesView, TemplateDetailView, AddTemplateView, ExercisesListView |
| `Unit/Features/History/` | HistoryView (list + calendar), SessionDetailView, PRLibraryView, ExerciseProgressView |
| `Unit/Features/Onboarding/` | Multi-step onboarding: splash, import, split builder, exercises, baselines, start date |
| `Unit/Features/Cycles/` | Legacy cycle views (unreachable from main navigation; retained for data compatibility) |
| `Unit/Features/Settings/` | SettingsView (weight unit, restart onboarding) |
| `Unit/Features/Subscription/` | PaywallView (one-time lifetime purchase) |
| `Unit/UI/` | `DesignSystem.swift` — atoms, molecules, organisms, and screen wrapper |

## Critical rules

- **Ghost values** are the primary way to pre-fill sets. The app looks up the last completed session for the same exercise (any template) and pre-fills weight + reps.
- `ProgressionEngine` is **deferred to post-v1**. It exists in code for backward compatibility with cycle-linked sessions but must not be surfaced in new template-based UI.
- Follow SwiftData schema (see `Unit/Models/`). New optional fields with defaults use lightweight migration automatically — no `VersionedSchema` needed.
- Optimize for the Gym Test: defaults, one-tap set completion, large CTAs.
- **Adaptive appearance**: Use design tokens (`Unit/UI/DesignSystem.swift`, `AppColor` / `AppFont` / etc.) — they support both light and dark modes via adaptive `UIColor`. All new UI must use tokens, not raw `Color(...)` or `.font(.system(...))`.
- HIG compliance: all interactive elements ≥ 44pt; never color alone for meaning; guard animated transitions with `@Environment(\.accessibilityReduceMotion)`.
- No social feed, no videos, no exercise discovery in core flow.

## Conventions

- `Unit/UI/DesignSystem.swift` is the single source of design tokens (`AppColor`, `AppFont`, `AppSpacing`, `AppRadius`, `AppIcon`, etc.). Add new tokens there.
- `PreviewSampleData` in `UnitApp.swift` seeds sample data for previews. Keep it up to date when adding models.
- Engine types (`WeekTarget`, `SessionOutcome`, `ProgressionRuleSnapshot`) are pure value types — no `@Model`, no SwiftUI imports in `ProgressionEngine.swift`.
