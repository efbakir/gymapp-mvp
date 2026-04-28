# Unit — MVP scope and push-back details

> Spillover from `CLAUDE.md` §2–§4. Read this when a task is on or near a scope boundary, when you need the full Ships / Does-not-ship list, or when you need the push-back phrasing template.

---

## Authoritative sources (cite in order of specificity)

1. `docs/goals.md` §v1 scope boundaries — the Ships / Does not ship list. Highest specificity.
2. `docs/product-compass.md` §Pillars (MVP boundary row) + §Decision log (2026-03-26 entries) — the *why* behind each boundary.
3. `CLAUDE.md` §3 — banned-list quick reference.

---

## v1 ships (from `docs/goals.md`)

- Template-based logging with ghost values
- Three onboarding paths: text-paste, redo-from-history, manual builder
- Auto rest timer with Lock Screen / Dynamic Island
- History view (list + calendar)
- Exercise library (search + custom exercise creation)
- Haptic confirmation on set logged
- PR detection + notification

## v1 does not ship (from `docs/goals.md` + compass decisions)

- `ProgressionEngine` (auto-increment, fail modes, deload)
- CloudKit sync
- Social features (feed, profiles, sharing)
- Exercise discovery / recommendation
- Subscription paywall on core logging
- 8-week cycles as primary container; "Week N of M" UI
- Day-N rigid numbering; target-vs-actual weight UI
- Plate calculator; conditioning days; pricing component on landing

## Files deleted from repo (do not recreate)

- `Unit/Engine/ProgressionEngine.swift`
- `Unit/Features/Cycles/*`
- `Unit/Models/Cycle.swift`
- `Unit/Models/ProgressionRule*.swift`
- `Unit/Features/Onboarding/OnboardingCycleStartView.swift`
- `Unit/Features/Onboarding/OnboardingProgressionView.swift`

If `git status` shows these as deleted — leave them deleted.

---

## Push back on (non-exhaustive)

- Anything on the "Does not ship" list above or `CLAUDE.md` §3 banned-list
- Net-new components when an existing atom/molecule/organism would do (`CLAUDE.md` §4)
- Dark-mode-first visual decisions
- Anything that adds taps, modals, or reading time to the Active Workout flow
- Adding tokens/variants/radii/weights when simplification would do

## Phrasing template

> "Before I do this — it conflicts with [rule] in [file:section]. The in-scope way to solve your underlying problem is [Y]. Want me to do Y instead, or is this an explicit override of the MVP boundary?"

If the user explicitly overrides ("yes, do it anyway / ignore the rule"), proceed — and note the override in your response so the deviation is visible, not silent.

## If the user asks for a banned thing

| Banned | If user asks |
|---|---|
| `ProgressionEngine`, auto-increment, deload rules | Offer ghost-value history as the in-scope alternative. |
| 8-week cycles, `Cycle`, `WeekDetailView`, "Week N of M" | Use template-based flow. |
| "Day N ·" rigid numbering prefixes | Use the template name. |
| Target-vs-actual weight UI in active workout | Ghost value prefill. |
| Plate calculator | Decline. |
| Social / sharing / feeds / community | Decline. |
| Exercise discovery / recommendation | Decline (athletes pick their own). |
| Pricing component on landing | Decline. |
| Conditioning days in imported programs | Filter on import. |
| CloudKit sync | Local-first only. |
| Paywall on core logging | Paywall only on non-core features. |
