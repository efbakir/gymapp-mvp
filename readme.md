# Unit

**A zero-friction, progression-guided gym logger.**

Unit lets beginner-to-experienced gym users choose a ready-made program or bring their own, then replaces the paper notebook and Notes app with a tool that survives gym fatigue. **Last time** pre-fills the previous weight and reps; one tap confirms a set. After training, optional transparent double progression suggests one next target without taking control of the program.

Authoritative product / design docs:

- **[`PRODUCT.md`](PRODUCT.md)** — persona, voice, anti-references, design principles
- **[`DESIGN.md`](DESIGN.md)** — palette, typography, components, do/don't (mirrored machine-readably in [`DESIGN.json`](DESIGN.json))
- **[`CLAUDE.md`](CLAUDE.md)** — session-level intent doc for AI agents working on this repo
- [`docs/product-compass.md`](docs/product-compass.md) — live positioning decisions and the decision log
- [`docs/goals.md`](docs/goals.md) — measurable targets and v1 scope boundaries
- [`docs/AGENTS.md`](docs/AGENTS.md) — UX rules, product model, scope fences

## Tech stack

- **Swift 6** (strict concurrency)
- **SwiftUI** (NavigationStack, custom `AppScreen` template)
- **SwiftData** (local-first; no CloudKit in v1)
- **iOS 18+**
- **Live Activities** (rest timer on Lock Screen / Dynamic Island)
- **Swift Charts** (history sparklines, progress views)
- **Geist / Geist Mono** (bundled `.ttf` fonts in `Unit/Resources/Fonts/`)

## Project structure

```
Unit/
  UnitApp.swift              — App entry, ModelContainer
  ContentView.swift          — Root tab navigation + AppScreen wiring
  UI/
    DesignSystem.swift       — Atoms, molecules, organisms, AppScreen template (single file)
  Models/
    DayTemplate.swift        — Template (split + ordered exerciseIds + planned sets/reps)
    Exercise.swift           — Exercise (displayName, aliases, isBodyweight)
    WorkoutSession.swift     — Session (date, templateId, isCompleted)
    SetEntry.swift           — Set (weight, reps, rpe, isWarmup, isCompleted, setIndex)
  Features/
    Today/                   — TodayView, ActiveWorkoutView, TrainingWeekProgress, RestTimerAttributes
    Templates/                — TemplatesView, TemplateDetailView, AddTemplateView, ProgramLibrary*
    History/                  — HistoryView (single list), SessionDetailView, ExerciseProgressView
    Onboarding/               — Splash, import method, program-import, split-builder, exercises
    Settings/                 — SettingsView (weight unit, restart onboarding)
    Subscription/             — PaywallView, StoreManager
    ProgramLaunch/            — Quick-start affordances
  Resources/
    Fonts/                   — Geist + Geist Mono .ttf files
docs/                        — Product, design, references, claude/ intent spillovers
```

## Data model (SwiftData)

- **DayTemplate** — id, name, splitId, orderedExerciseIds, planned targets, optional JSON-backed per-exercise progression state, lastPerformedDate
- **Exercise** — id, displayName, aliases, notes, isBodyweight
- **WorkoutSession** — id, date, templateId, isCompleted
- **SetEntry** — id, sessionId, exerciseId, weight, reps, rpe, isWarmup, isCompleted, setIndex

**Rule:** Last-time values are computed at read-time from the most recent completed `SetEntry` for the same exercise (any template). An explicitly accepted progression target is persisted per routine/exercise and takes precedence for the next matching workout.

## Out of v1 scope

The following were intentionally cut or deferred — see [`docs/claude/scope.md`](docs/claude/scope.md) for the full list:

- Legacy cycle/failure/deload progression logic → excluded; v2.1 ships only opt-in, transparent double progression after a workout
- 8-week cycles, `Cycle`, `WeekDetailView`, "Week N of M" → templates replace cycles
- Target-vs-actual weight columns → last-time pre-fill only
- Plate calculator, social / feeds / sharing, exercise discovery → not for this product
- CloudKit sync → local-first only
- ~~Paywall on core logging~~ → lifted 2026-06-16; v2 ships a hard paywall after onboarding (see `docs/pricing.md`)

## Build and run

1. Open `Unit.xcodeproj` in Xcode 16+.
2. Select the **Unit** scheme and an iPhone simulator running iOS 18+.
3. Build and run (⌘R).

The **UnitWidgetExtension** target is built alongside the app and provides the rest timer Live Activity.

## License

Proprietary.
