# AGENTS.md — Rules for AI agents working on Unit

> Read `product-compass.md` before every task. If a compass decision contradicts something in this file, the compass wins.

---

## What Unit is (post-pivot, 2026-03-26)

Unit is a **zero-friction gym logging tool** for intermediate-to-advanced lifters. The primary metric is **seconds per set logged**. It is not an AI coach, not a social platform, and not a periodisation planner.

**Core loop:** Open app → see today's template → tap Start → log sets with one tap each → finish.

---

## Architecture rules

| Rule | Detail |
|------|--------|
| **Language** | Swift 6, strict concurrency |
| **UI** | SwiftUI only. Every view uses the atomic design system (`DesignSystem.swift`). No raw values in view files. |
| **Data** | SwiftData, local-first. No network calls required for core functionality. |
| **Design system** | Read `DESIGN_SYSTEM.md` before creating or modifying any view. No exceptions. |
| **Screen wrapper** | Every screen uses `AppScreen`. No custom nav bars. |
| **No chevrons** | `chevron.right` and `chevron.forward` are banned everywhere except the system back button. |

---

## Product model (current)

| Concept | What it is now | What it is NOT |
|---------|---------------|----------------|
| **Template** | A lightweight, repeatable collection of exercises (e.g. "Push Day A"). Not bound to a week or cycle. The primary program unit. | Not an 8-week cycle. Not a periodisation plan. |
| **Session** | A single workout instance. May be linked to a template or freestyle. | Not a "Day" within a numbered week. |
| **Ghost values** | Pre-filled weight/reps from the most recent session for that exercise, queried globally across all templates. | Not a target set by the engine. Not per-template. |
| **"No history yet"** | Shown when an exercise has never been logged anywhere. Fields are empty; user fills in manually. | Not "0 kg". Never show 0 as a default. |
| **Rest timer** | Auto-starts on "Done" tap. Visible on Lock Screen and Dynamic Island. | Not optional / hidden. |
| **Cycles** | An optional organisational layer. Not required. Not shown prominently. | Not the main container. Not mandatory. |
| **ProgressionEngine** | Deferred to post-v1. Code may exist in `ProgressionEngine.swift` but is not active in the UI. | Not exposed to users in v1. Do not build new engine features. |

---

## UX rules

- **Gym Test:** A user must be able to log a set in ≤ 3 seconds under physical stress.
- **One-tap Done:** The primary interaction is a large (44×44 pt minimum) "Done" button/checkbox. Haptic feedback on tap.
- **No keyboard for happy path:** Ghost values mean the user never types during a normal set. Keyboard only appears when the user explicitly edits a value.
- **≤ 2 taps to start:** From app launch to first logged set must be 2 taps or fewer (Today → Start → Done).
- **No social features.** No feed, no likes, no leaderboards, no sharing prompts.

---

## Onboarding

Three paths to creating a template, all shipping in v1:

1. **Text-paste import** — user pastes a routine from Notes/WhatsApp. Basic exercise name-matching builds a structured template.
2. **Redo-from-history** — one-tap conversion of any past freestyle session into a saved template.
3. **Manual builder** — search-and-add exercises to a new template.

---

## What NOT to build (v1 scope fences)

- CloudKit sync
- Exercise discovery feed
- Social / community features
- Algorithmic progression (auto-increment, fail modes, deload rules)
- Mandatory cycle/week/day structure
- Subscription gate on core logging
- Any feature that increases taps-to-log

---

## When in doubt

Ask: "Does this make logging a set faster or slower?" If slower, don't ship it in v1.
