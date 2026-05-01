# Unit — Decision Log

> Append-only chronological record of decisions, scope overrides, and direction shifts.
> One entry per decision. Newest at the top. Never edit or delete past entries — strike them through and write a new entry that supersedes.

**What goes here:**
- Scope decisions (added / cut / deferred)
- Design system overrides (the user explicitly green-lit a deviation from `CLAUDE.md` §3 / §4)
- Direction shifts (pivot, persona update, KPI change)
- Bets that did or did not pay off (so we don't redo the same experiment)
- Notable in-session course corrections that aren't captured elsewhere

**What does NOT go here:**
- Per-task work logs — that's git history
- Bug fixes — that's git history
- Code review notes — that's PRs
- Anything captured in `~/.claude/projects/.../memory/` (use the index there)

**Format:** `## YYYY-MM-DD — <one-line title>`, then 2–4 lines: *Decision*, *Why*, *Implication*. If superseded later, add `**SUPERSEDED by YYYY-MM-DD**` on the original.

---

## 2026-05-01 — Started this decision log

**Decision:** Add `docs/decision-log.md` as the append-only record for cross-session decisions.
**Why:** Existing memory + `CLAUDE.md` capture *current state*; they don't capture *what changed and why*. Karpathy's LLM-wiki pattern points at the gap — decisions evaporate at session end unless they make it into a memory file. A flat log is cheaper than a full wiki overhaul.
**Implication:** Future sessions read this on any "why did we…" question. Pair with monthly `consolidate-memory` runs to keep `~/.claude/.../memory/` honest.

---

<!-- new entries above this line -->
