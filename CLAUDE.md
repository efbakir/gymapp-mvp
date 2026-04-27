# Unit — Claude Code context

> This file is the session-level **intent document**. Read it, internalize it, then act.
> Framework: centralize intent → distribute execution → feedback loop. You get the *why*; decide the *how* within these fences.
> If a request in this session conflicts with anything here, **pause and push back before executing**. That is the job.

---

## 1. North star (one sentence)

**Unit is a zero-friction gym logger. Every decision is judged by *seconds per set logged under fatigue*. Everything else is secondary.**

Non-negotiables that flow from this:
- **Gym Test**: one-handed, sweaty, ≤ 3 seconds to log a set.
- **Ghost values** (pre-fill from last session) are the primary logging mechanism.
- **Templates** are the program unit — not cycles, not weeks, not engines.
- **Local-first, light-first, quiet UI.** No social, no feeds, no recommendations.

Source of truth docs: `docs/product-compass.md`, `docs/goals.md`, `AGENTS.md`, `DESIGN_SYSTEM.md`, `docs/atomic-design-system.md`, `docs/visual-language.md`.

---

## 2. Push-back mandate (read this before accepting any task)

The user has explicitly said: *"you should be better than me here — I should not repeat myself every prompt."* Translation: **drift prevention is your job, not theirs.**

When the user asks for something that violates this file — push back **before** writing code. Cite the rule. Offer the in-scope alternative. Do not silently comply and let the app grow messier.

### MVP scope — authoritative sources (cite these when pushing back)

1. **`docs/goals.md` §v1 scope boundaries** — the Ships / Does not ship list. Highest-specificity MVP reference.
2. **`docs/product-compass.md` §Pillars (MVP boundary row) + §Decision log (2026-03-26 entries)** — the *why* behind each boundary.
3. **`CLAUDE.md` §4** (this file) — banned-list quick reference.

### MVP v1 scope (pinned inline so pushback doesn't require a file fetch)

**Ships in v1** (`docs/goals.md`):
- Template-based logging with ghost values
- Three onboarding paths: text-paste, redo-from-history, manual builder
- Auto rest timer with Lock Screen / Dynamic Island
- History view (list + calendar)
- Exercise library (search + custom exercise creation)
- Haptic confirmation on set logged
- PR detection + notification

**Does not ship in v1** (`docs/goals.md` + compass decisions):
- `ProgressionEngine` (auto-increment, fail modes, deload)
- CloudKit sync
- Social features (feed, profiles, sharing)
- Exercise discovery / recommendation
- Subscription paywall on core logging
- 8-week cycles as primary container; "Week N of M" UI
- Day-N rigid numbering; target-vs-actual weight UI
- Plate calculator; conditioning days; pricing component on landing

### Push back on (non-exhaustive)

- Anything on the "Does not ship" list above or §4 banned-list
- Net-new components when an existing atom/molecule/organism would do (§5)
- Dark-mode-first visual decisions
- Anything that adds taps, modals, or reading time to the Active Workout flow
- Adding tokens/variants/radii/weights when simplification would do

### Phrasing template

*"Before I do this — it conflicts with [rule] in [file:section]. The in-scope way to solve your underlying problem is [Y]. Want me to do Y instead, or is this an explicit override of the MVP boundary?"*

If the user explicitly overrides ("yes, do it anyway / ignore the rule"), proceed — and note the override in your response so the deviation is visible, not silent.

---

## 3. Session-start checklist (before the first Edit/Write)

1. Read this file to the end.
2. If the task involves UI, product direction, or scope: skim `docs/product-compass.md` §Pillars + §Decision log **and** `docs/goals.md` §v1 scope boundaries.
3. If the task involves any visual/component change: skim `docs/atomic-design-system.md` and open `Unit/UI/DesignSystem.swift` to see what atoms/molecules already exist. Reuse > extend > create.
4. State out loud (one line) which docs you consulted and what constraint applies. Then proceed.

---

## 4. Scope fence — banned from v1 (do not resurrect, do not propose)

Per compass decision 2026-03-26, these are **removed** or **deferred**. Claude keeps trying to re-add them. Stop.

| Banned | Why | If user asks |
|---|---|---|
| `ProgressionEngine`, auto-increment, deload rules | Deferred post-v1 (compass 2026-03-26). Deleted from main UI. | Offer ghost-value history as the in-scope alternative. |
| 8-week cycles, `Cycle`, `WeekDetailView`, "Week N of M" | Demoted to optional layer. Templates replace cycles. | Use template-based flow. |
| "Day N ·" rigid numbering prefixes | Banned (audit-prompt). Use template/routine names. | Use the template name. |
| Target-vs-actual weight UI in active workout | Banned. Ghost values only. | Ghost value prefill. |
| Plate calculator | Explicitly skipped. | Decline. |
| Social / sharing / feeds / community | Anti-persona. Compass §User segment. | Decline. |
| Exercise discovery / recommendation | Athletes choose their own exercises. | Decline. |
| Pricing component on landing | Removed. | Decline. |
| Conditioning days in imported programs | Filter out. | Filter on import. |
| CloudKit sync | Post-v1. | Local-first only. |
| Paywall on core logging | Core logging is free. | Paywall only on non-core features. |

Files deleted from repo (see `git status` — don't recreate): `Unit/Engine/ProgressionEngine.swift`, `Unit/Features/Cycles/*`, `Unit/Models/Cycle.swift`, `Unit/Models/ProgressionRule*.swift`, `Unit/Features/Onboarding/OnboardingCycleStartView.swift`, `Unit/Features/Onboarding/OnboardingProgressionView.swift`.

---

## 5. Design system — hard rules

### The 5 principles (apply to every UI decision)

1. **Keep it simple.** Default to removing, not adding. Fewer tokens, fewer variants, fewer words, fewer screens. If a change grows the system, justify it out loud before shipping. (See §8 for the simplification bias.)
2. **Reuse components. Do not create new ones.** Before writing any new `View`, grep `Unit/UI/DesignSystem.swift` and the existing molecules/organisms. If something ~80% fits — use it or extend it. Duplicates are worse than imperfect reuse. *Creating a parallel component is an explicit decision that requires the user's okay.*
3. **Light mode only.** The app is light-mode only. No dark-mode styling, no `.preferredColorScheme(.dark)`, no dark-first visual decisions. Tokens may have dark values for system compatibility, but visual review and screenshots happen in light mode.
4. **Portrait only.** The app does not rotate. Landscape is not supported. Never design for or test in landscape. If you touch orientation config, keep it locked to portrait.
5. **Gatekeeper every UI change.** Before Edit/Write on any `.swift` view file, run the checklist below. Fail-closed: if a gate fails, fix it before proceeding or flag it to the user.

### Parallel-implementation ban (the #1 current drift)

The most frequent recent failure mode: Claude **invents a new struct / helper / modifier / variant when extending the existing canonical one would do.** This is worse than any hex literal, because it bakes drift into the design system itself.

Concrete violations from recent sessions (do not repeat):
- Created `AppStackedCardList` instead of extending `AppDividedList` with a `style:` param.
- Kept an `appScrollEdgeSoftTop(enabled:)` helper using `.automatic` when the only correct value is `.soft` and both edges should be covered — canonical is `appScrollEdgeSoft(top:bottom:)`.
- Added `.font(...).weight(.semibold)` on `TodayView` toolbar buttons while every other view used iOS-native default weight.
- Reached for `AppSecondaryButton(tone: .accentSoft, icon: .add)` where `AppGhostButton` was the right atom.
- Wrapped `.sheet` content in `ScrollView { AppCard { ... } }` — sheets already provide chrome.
- Fixed a LinearGradient fade inline on a screen when the canonical `appScrollEdgeSoft` already existed.

Rules:
1. **Default: extend > create.** Before declaring any new `struct X: View` (or new `ViewModifier`, or new variant token) in `Unit/UI/DesignSystem.swift`, grep the file for the closest existing primitive. If one covers ~80%, extend it with a `style:` / `variant:` / `tone:` param. If you still want to create a new one, state the justification in one sentence. *No silent new primitives.*
2. **One canonical modifier per concern.** `scrollEdgeEffectStyle` lives behind `appScrollEdgeSoft(top:bottom:)`. Fades behind bars live behind the same modifier. Never add a parallel `LinearGradient` mask to a `Features/**/*.swift` view to achieve the same effect.
3. **Fix the canonical, migrate callers, don't fork.** If the canonical helper is wrong, update it and its callers in the same change. Do not leave the old one limping while the new one ships.
4. **Toolbar chrome defers to iOS-native.** No `.weight(.semibold/.bold/.heavy)` on `ToolbarItem` buttons unless every toolbar in the app uses the same weight. Prefer iOS default.
5. **Sheet roots are plain `VStack`.** `.sheet { }` content does not need its own `ScrollView` + `AppCard` wrapper. Sheets have chrome.

Cross-reference with the canonical-modifiers memory: `feedback_unit_scroll_edge_soft.md`.

### Gatekeeper checklist (run before every UI Edit/Write)

- [ ] I opened `Unit/UI/DesignSystem.swift` and checked whether an existing atom/molecule/organism already fits. (Principle 2)
- [ ] **If this change introduces a new component / UI pattern / behavior not already in the design system, I cited a source of truth before the diff** — repo first (`docs/product-compass.md`, `docs/atomic-design-system.md`, `docs/visual-language.md`, `AGENTS.md`, `Unit/UI/DesignSystem.swift`), web second (Apple HIG, lawsofux, NN/g, growth.design). If neither covers it, I asked the user before proceeding. (See `feedback_unit_research_before_new_patterns.md`)
- [ ] **I am not adding a new `struct X: View` or new `ViewModifier` without a one-line justification of why extending the nearest primitive wouldn't work.** (Parallel-ban rule 1)
- [ ] **I am not adding a parallel `LinearGradient` / `.mask` / `.scrollEdgeEffectStyle(.automatic, ...)` when `appScrollEdgeSoft(...)` is the canonical modifier.** (Parallel-ban rule 2)
- [ ] The change introduces no new raw colors, fonts, spacings, or radii — only tokens. (§Banned below)
- [ ] The change adds no net-new component without the user's explicit okay. (Principle 2)
- [ ] The change is light-mode correct. No dark-mode-first decisions. (Principle 3)
- [ ] The change does not assume landscape or rotated layout. (Principle 4)
- [ ] If this is a bug fix, I confirmed whether the bug is at the atom/molecule layer. **If yes, I fix only `DesignSystem.swift` — not also the feature file.** (§6)
- [ ] If I edited a `ToolbarItem` button, I did not add `.weight(...)` unless I'm changing the convention app-wide in the same turn.
- [ ] If I edited `.sheet { }` content, the root is a plain `VStack` (no `ScrollView` / `AppCard` wrapper). Use `presentationDetents` for height.
- [ ] The screen is wrapped in `AppScreen`. All CTAs use `AppPrimaryButton`. Cards use `AppCard` / `appCardStyle()`. No `chevron.right`. No `Divider()` where `AppDivider` applies.
- [ ] Touch targets ≥ 44×44pt. No regular font weight. No orange `#FF4400` (accent is `0x0A0A0A`).
- [ ] Copy is explicit, not a `–` / `—` placeholder. Bodyweight shows "BW", not "0 kg".
- [ ] No `ProcessInfo.processInfo.environment["UNIT_*"]` / `UNIT_START_TAB` / `UNIT_AUTO_OPEN` screenshot-scaffolding left in `ContentView.swift` or any `Features/**/*.swift`. Revert temp scaffolding before turn end.

### Banned in view code (strict — no silent exceptions)

- Hex literals, `Color(red:green:blue:)`, `Color.black/.white/.gray/.red/.green/.blue/.primary/.secondary`
- `.foregroundStyle(.gray)` / `.foregroundColor(.gray)`
- `.font(.system(size:...))`, raw `.font(.body/.caption/.title)` where an `AppFont.*` applies
- Hardcoded paddings (`.padding(16)`, `.padding(.horizontal, 20)`) — use `AppSpacing.*`
- Hardcoded corner radii — use `AppRadius.*`
- `chevron.right` / `chevron.forward`
- `Divider()` where `AppDivider` is required
- Inline button styling for primary CTAs — use `AppPrimaryButton`
- Inline card chrome — use `AppCard` / `appCardStyle()`
- Screens not wrapped in `AppScreen`
- `regular` font weight
- Orange accent `#FF4400` (replaced by darkest black `0x0A0A0A`)
- `.preferredColorScheme(.dark)` or any dark-mode-first styling decision
- Any landscape-only layout assumption
- "0 kg" for bodyweight exercises (show "BW" or "No history yet")
- En-dash `–` / em-dash `—` as placeholder copy — write the explicit string
- `.scrollEdgeEffectStyle(.automatic, ...)` or `.hard` — always `.soft`, and route through `appScrollEdgeSoft(top:bottom:)`, never inline
- `LinearGradient` / `.mask` used as a fade under a fixed bar in `Features/**/*.swift` — use `appScrollEdgeSoft` only
- `.font(...).weight(.semibold/.bold/.heavy)` on `ToolbarItem` buttons — iOS-native default weight
- `AppSecondaryButton(tone: .accentSoft, icon: .add, ...)` as a section "Add X" trigger — use `AppGhostButton`
- `ScrollView` or `AppCard` as the **root** child of `.sheet { }` — use plain `VStack` with `presentationDetents`
- `ProcessInfo.processInfo.environment["UNIT_*"]` scaffolding committed in `ContentView.swift` or any `Features/**/*.swift` — test-only, must be reverted before turn end
- Any new `struct X: View` / new `ViewModifier` / new variant added to `Unit/UI/DesignSystem.swift` **without an explicit one-line justification** of why the nearest existing primitive couldn't be extended (see Parallel-implementation ban)

`Unit/UI/DesignSystem.swift` is the **only** place raw values live. Every other file uses tokens. No exceptions without the user's explicit override.

**Prefer iOS-native over custom**: bottom sheets, tab bar chrome, buttons, arrows, navigation. Custom chrome only when system primitives genuinely can't express the design.

---

## 6. Fix level — atoms > molecules > screens

If a visual/spacing/shadow/radius/color bug appears on one screen, it is **almost always an atom or molecule problem**. Fix it there. The user has said this repeatedly:

> "apply design system rules. follow the design system. make it consistent. make it system level"
> "identify the inconsistencies and fix them in the atom and molecules level"
> "Make a system-level improvement … across the app"

Rule: after any visual fix, ask "would this bug appear on sibling screens if I only patched this one file?" If yes, **move the fix up a layer** — to `Unit/UI/DesignSystem.swift` (or the specific molecule/organism file) — so every screen benefits in one change.

---

## 7. Verification gates — before saying "done"

Do **not** declare a task done based on the code looking right. Until you have verified, say: *"edits applied, not yet verified."*

For **code changes that compile**:
- Build succeeds (`xcodebuild` or similar).

For **UI/visual changes**:
- Build + install + launch on iOS Simulator.
- Screenshot the affected screen(s) via `xcrun simctl io booted screenshot`.
- Visually confirm the change. Flag padding/alignment/shadow drift even if not asked.
- If the change is system-level (atoms/molecules), screenshot **at least 2 sibling screens** to confirm no regression.

If you cannot verify (tooling/build broken), say so plainly. Never fake it. The user has called this out: *"still buggy", "still containing the shadow", "i cant launch the app"* — these are all failures to verify.

---

## 8. Simplification bias

When deciding between:
- adding vs removing → prefer **removing**
- extending a token set vs collapsing → prefer **collapsing**
- new variant vs reuse → prefer **reuse**
- explaining in copy vs making it obvious → prefer **making it obvious, then cutting the copy**

User quotes: *"radius font size etc they are too much. even colors are too much. simplify."* / *"trying to simplify the app."*

If a change grows the design system rather than tightening it, justify the growth explicitly or don't ship it.

---

## 9. Audit mode (preserved)

When running an audit task (invoked by the overnight cron or `audit-prompt.md`), Claude should:

1. Read `docs/product-compass.md` first — source of truth
2. Read `AGENTS.md` (or `docs/AGENTS.md`) for UX rules and scope fences
3. Read `DESIGN_SYSTEM.md` (points to `docs/atomic-design-system.md` and `docs/visual-language.md`)
4. Read `docs/goals.md` for measurable targets and v1 scope boundaries
5. Scan every SwiftUI view file
6. Build and run the app in the iOS Simulator
7. Take screenshots of every reachable screen
8. Compare each screenshot against the compass, design system, and goals
9. Write findings to `audit-report.md` in the repo root (or a timestamped report if invoked via script)

The full audit checklist is in `audit-prompt.md`. Use it as the enforcement surface for Design System Violations and Compass Alignment sections of the report.
