# Unit — Harness (hooks, skills, audit mode)

> Spillover from `CLAUDE.md` §8. The user has repeated the same UI rules across 30+ sessions, so three layers of enforcement now exist so Claude does not have to "remember".

---

## 1. PreToolUse hook (`.claude/hooks/ui-banned-list.sh`)

Registered in `.claude/settings.json`. Fires before every `Edit` / `Write` / `MultiEdit` and **blocks** (exit 2) if the new content introduces any of the design-system banned patterns into a Swift file under `Unit/` (excluding `Unit/UI/DesignSystem.swift`, where tokens are defined).

### Patterns blocked

- `chevron.right` / `chevron.forward`
- `Color(red:..)`, `Color.black/.white/.gray/.red/.green/.blue/.primary/.secondary`
- Hex literals (`0xRRGGBB[AA]`)
- `.foregroundStyle(.gray)` / `.foregroundColor(.gray)`
- `.font(.system(size:))`, `.padding(<int>)`, `.cornerRadius(<int>)`, `RoundedRectangle(cornerRadius: <int>)`
- `.preferredColorScheme(.dark)`
- `.scrollEdgeEffectStyle(.automatic)` / `.hard`
- `.weight(.regular)`, `#FF4400` / `0xFF4400`
- `Text("–")` / `Text("—")` / `Text("0 kg")` placeholders
- `ProcessInfo.processInfo.environment["UNIT_*"]` scaffolding
- `ToolbarItem` + `.weight(.semibold/.bold/.heavy)` together
- `.sheet { ScrollView … }` (heuristic)
- `AppCard(contentInset: 0)` outside `DesignSystem.swift`
- Hand-composed `AppCard { AppDividedList(…) }` outside `DesignSystem.swift`

### Non-blocking notes

The hook surfaces a non-blocking note when a new `struct X: View` appears in a Features file, prompting reuse-check.

### If the hook blocks legitimate work

The fix is to update the canonical primitive in `DesignSystem.swift` (which the hook exempts). **Do NOT edit the hook to allow the violation** — that defeats the purpose. There is no `--no-checks` escape hatch; the hook fires unconditionally. If the user explicitly overrides, route the work through the canonical layer.

---

## 2. Project skills (`.claude/skills/`)

Three skills enforce the rest of the gatekeeper checklist where a hook can't:

| Skill | When to invoke | Replaces |
|---|---|---|
| `/page-audit` | Before any single-screen review or polish task. Loads `CLAUDE.md` §3–§6, `DesignSystem.swift`, the closest `docs/references/` anchor, and produces a severity-ranked report tied to atom/molecule/screen layers. | Asking "is this consistent with the system?" then guessing. |
| `/component-reuse-check` | Before declaring any new `struct X: View` / `ViewModifier` / variant. Surveys existing primitives, runs the 80% match test, returns USE / EXTEND / NEW with one-sentence justification. | Inventing parallel components. |
| `/ui-visual-verify` | After any UI Edit/Write, before saying "done". Build → screenshot → describe what is actually visible → certify VERIFIED / NOT VERIFIED / WAIVED. | Claiming success based on the code looking right. |

These exist because the user has explicitly said: *"you should be better than me here — I should not repeat myself every prompt."* Trigger them proactively. Do not wait for the user to type the slash command.

---

## 3. Visual references (`docs/references/`)

Aesthetic taste is not text-encodable. `docs/references/` holds screenshots of iOS apps Unit's design language is anchored to (Apple Sports, Streaks, Things 3, etc.). Before any non-trivial UI edit, name the closest anchor and what specifically is being borrowed. See `docs/references/README.md` for the convention.

If `docs/references/` has no anchor for the screen type at hand, **say so before editing**. Do not invent visual decisions — ask the user for a reference, or pick the closest existing one and justify why.

---

## 4. Order of operations for any UI task

1. Run the `CLAUDE.md` §1 session-start checklist (docs + references).
2. If proposing a new component: run `/component-reuse-check` first.
3. Make the edit. Hook fires automatically — fix any blocked patterns at the canonical layer.
4. Run `/ui-visual-verify` before saying done.
5. If the task was a single-screen review/polish: run `/page-audit` either at start (to plan the change) or end (to confirm nothing else drifted).

---

## 5. Audit mode

When running an audit task (invoked by the overnight cron or `audit-prompt.md`), Claude should:

1. Read `docs/product-compass.md` first — source of truth.
2. Read `docs/AGENTS.md` for UX rules and scope fences.
3. Read `DESIGN.md` (root — palette, type, components, do/don't) and `DESIGN_SYSTEM.md` (entrypoint to `docs/atomic-design-system.md` and `docs/visual-language.md`).
4. Read `docs/goals.md` for measurable targets and v1 scope boundaries.
5. Scan every SwiftUI view file.
6. Build and run the app in the iOS Simulator.
7. Take screenshots of every reachable screen.
8. Compare each screenshot against the compass, design system, and goals.
9. Write findings to `audit-report.md` in the repo root (or a timestamped report if invoked via script).

The full audit checklist is in `audit-prompt.md`. Use it as the enforcement surface for Design System Violations and Compass Alignment sections of the report.
