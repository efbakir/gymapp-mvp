# Unit — Product compass

**Purpose:** Single place to record **what we believe now**, **what we decided**, and **what we’re no longer sure about**. Use it before changing positioning, the website, or MVP scope. Update this file when you make a call—future you (and agents) should read this before rewriting copy or features.

**How to use**

1. Skim **§ Prior decisions (archaeology)** when you’re about to change direction—know what the codebase and older docs assumed.
2. Edit **§ Living compass** when your north star shifts.
3. Append rows to **§ Decision log** with a date and owner; link PRs or issues if useful.
4. Park unresolved tension in **§ Open questions** until it graduates to a decision.

---

## Living compass (edit freely)

| Pillar | Current intent (fill in / revise) |
|--------|-------------------------------------|
| **North star** | *e.g. “Fast, trustworthy logging under fatigue” vs “Hands-off progression coach”* |
| **Non-negotiables** | *e.g. Gym Test, local-first, no social feed* |
| **MVP boundary** | *What ships v1: logging-only slice vs cycles + engine vs hybrid* |
| **Voice** | *How bold/plain the site and App Store copy should be* |

---

## Decision log

| Date | Decision | Rationale (short) | Supersedes |
|------|----------|---------------------|------------|
| *YYYY-MM-DD* | *Example: Hero headline emphasizes X, not Y* | *…* | *—* |

---

## Open questions

*Track debates here until they become decisions.*

- **Simplicity vs engine:** Is the *primary* promise “simple tracking” with progression as a power feature, or is auto-adjustment still the headline differentiator?
- **MVP scope:** Must v1 include 8-week cycles + `ProgressionEngine` for all users, or can a thinner “log + program” path ship first?
- **Positioning line:** Retain comparison to Strong/Hevy or avoid competitor-framed copy on the site?

---

## Prior decisions (archaeology)

*Synthesized from existing repo docs (`readme.md`, `docs/product-manifesto.md`, `docs/app-positioning.md`, `docs/goals.md`, `docs/custom-instructions.md`, `AGENTS.md`). This is **not** a commitment to keep them—it’s context for the next decision.*

### Product & positioning (historical)

- **Core narrative (historical):** Unit was framed as an **Adaptive Periodization Engine**, not a passive logger. “Logging without progression is bookkeeping.”
- **Single differentiator (historical):** *“The only gym logger that auto-adjusts your 8-week plan when you fail.”* (see `docs/app-positioning.md`, `readme.md`, marketing site).
- **Primary user (historical):** Intermediate–advanced lifter on a **structured program**, frustrated that apps show history but not **what to lift next**.
- **UI paradigm (historical):** **Target vs actual**—target weight shown before the set; engine updates future weeks on misses/deload rules.
- **Container (historical):** **8-week cycle** as the main product container; per-exercise rules (increment, base weight, failure tolerance).

### Engine rules (as implemented in product story)

- Hit target → increment next week (conceptually).
- Miss → repeat weight.
- Three consecutive misses → **10% deload**, failure count resets.

### Execution constraints (still largely active)

- **Gym Test:** Log a set in **under ~3 seconds** under stress (`docs/goals.md`, `AGENTS.md`, design docs).
- **Tech:** Swift 6, SwiftUI, SwiftData, local-first; targets for progression should go through **`ProgressionEngine.swift`** (see `AGENTS.md`).
- **Design:** Light-first, atomic design system, minimal noise (`docs/visual-language.md`, `docs/custom-instructions.md`).
- **Out of scope (historical launch list):** e.g. CloudKit sync at v1, exercise discovery feed (`docs/goals.md`).

### Monetization & distribution (historical hints)

- Positioning doc: premium **one-time or subscription**; engine as differentiator.
- Marketing FAQ: **one-time purchase**, offline, restore via Apple ID.

### Tension you’re resolving now

Older docs **optimize for the engine story** (coach, not clipboard). Your current instinct (**radically simple logging + keeping track**) can coexist with the engine (logging-first MVP, engine optional or phased) or **reprioritize** copy and scope. This compass is where that gets **explicit** so website, `readme.md`, and `docs/app-positioning.md` don’t drift silently.

---

## Related files to keep in sync (when decisions land)

| Surface | Path |
|---------|------|
| Marketing site hero / meta | `app/(marketing)/page.tsx` |
| Repo elevator pitch | `readme.md` (opening) |
| Positioning one-pager | `docs/app-positioning.md` |
| Manifesto / narrative depth | `docs/product-manifesto.md` |
| Measurable goals | `docs/goals.md` |
| Agent rules | `AGENTS.md` |

When you lock a new direction, update the compass **first** (decision log), then cascade to the rows above.
