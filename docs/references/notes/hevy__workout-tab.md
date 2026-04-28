---
anchor: docs/references/ios-screens/hevy__workout-tab.png
---

# hevy__workout-tab

Closest **structural** anchor for Unit's Templates tab (and arguably the Today/Home surface). Direct competitor — useful precisely because their information architecture maps almost 1:1 to ours.

**Borrow:**
- Sectioned home structure, top-to-bottom: `Quick Start` (single primary action) → `Routines` (two-column action tiles: New / Explore) → grouped routines per program (`PPL (Push/Pull/Legs)` with kebab) → `My Routines` (saved templates, one card each, Start CTA per row) → docked `Workout in Progress` indicator at bottom.
- The `Workout in Progress` resume/discard pattern when the user has an active workout. Unit needs this exact affordance for ActiveWorkoutView re-entry.
- Two-column action tiles (`New Routine` / `Explore`) as a way to expose two equivalent entry points without making one feel demoted.
- Per-template card showing name + truncated exercise list as one-line preview before the CTA. Good density for the template list.

**Do NOT borrow:**
- The **iOS-blue everywhere** (Resume link, Start Routine button, "+ Add new routine" link). Unit's primary CTA is `AppPrimaryButton` (black `0x0A0A0A`), not blue, and full-width on its own line — not link-style.
- The **dashed-outline placeholder** for "Add new routine". Unit doesn't use dashed strokes; use `AppCardListAddRow` (canonical) for the add affordance inside a list-in-card.
- "Resume" / "Discard" as plain text links. The active-workout resume entry should be a real button surface, not a text link.
- The kebab `•••` overflow menu pattern on every section. Use it sparingly — only where the row genuinely has 3+ secondary actions worth hiding.
