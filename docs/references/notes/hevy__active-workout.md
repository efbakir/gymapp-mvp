---
anchor: docs/references/ios-screens/hevy__active-workout.png
---

# hevy__active-workout

The **direct competitor** anchor for ActiveWorkoutView. Critical to read this note before borrowing anything: Hevy's paradigm (row-list, all sets visible) is the **opposite** of Unit's chosen paradigm (single-card command panel, one set at a time). Borrow per-row *hierarchy* and the conceptual model — never the row-list structure.

**Borrow:**
- The **`PREVIOUS` column** as the canonical place where prior-session values live. Hevy hides it in a column; Unit promotes it to the metric hero. Same north star (the §1 ghost-value mechanism), two different surfaces. Useful as a benchmark for *what data the user expects to see*, not how to lay it out.
- **Per-exercise rest-timer state** (each exercise card shows its own `Rest Timer: 1min 5s` chip). Matches Unit's per-exercise timer concept. The chip placement (under exercise title, with a small clock prefix) is the right informational density.
- **Warm-up rows distinct from working sets** — Hevy uses a `W` label in the SET column; Unit uses a separate `WarmupRow` molecule. Conceptually identical. The "warm-ups don't count toward planned sets" model is right.
- **Top summary strip** (`Duration` / `Volume` / `Sets`) — three monospaced numerics across the top of the screen. Useful pattern if Unit ever ships a session-totals strip on ActiveWorkoutView.
- **`+ Add Set` row at the bottom of each exercise** — quiet ghost-button affordance, full row width. Unit's equivalent is `AppCardListAddRow`.

**Do NOT borrow:**
- ❌ **The row-list paradigm itself.** Hevy renders every set as a row in a table; Unit renders one exercise's current set as a single command card. Per CLAUDE.md §1, the Gym Test is *≤ 3 seconds per set logged under fatigue* — row lists require reading multiple cells under sweat; command panels require one tap. The two paradigms are not interchangeable. Anything that nudges Unit toward "show all sets at once" is drift away from the north star.
- ❌ **Table-style column headers** (`SET / PREVIOUS / KG / REPS / ✓`). Unit doesn't render data tables in the active workout. Banned by simplification bias.
- ❌ **`0 kg` / `0` placeholders** in unfilled rows — banned by CLAUDE.md §5 (`Text("0 kg")` is on the banned list). Unit hides empty values or shows "BW" / "No history yet".
- ❌ **`—` em-dash placeholder** in the `PREVIOUS` column when there's no prior value — banned by CLAUDE.md §5 (`Text("—")` is explicit). Use full copy.
- ❌ **iOS-blue everywhere** (exercise names, summary numbers, `Finish` pill, timer labels). Unit accent is `0x0A0A0A`.
- ❌ **Kebab `•••` overflow per exercise.** Banned per the no-overflow-menus pattern. If a row needs more actions, surface them inline or via a long-press, not a kebab.
- ❌ **`Add notes here…` inline placeholder** under each exercise name. Unit handles notes via `AdjustResultSheet`, not as always-visible per-exercise inline text. Adds noise.
