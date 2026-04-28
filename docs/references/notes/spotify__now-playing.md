---
anchor: docs/references/ios-screens/spotify__now-playing.png
---

# spotify__now-playing

> ⚠️ **DARK MODE / ALBUM-ART GRADIENT.** Unit is light-mode only (CLAUDE.md §5). This reference is kept for **structure and idiom only** — ignore every color, gradient, and surface decision. Re-derive in light mode.

Out-of-domain anchor for the **single-card command-panel idiom**. Spotify's Now Playing is structurally identical to Unit's `WorkoutCommandCard`: minimal top chrome → primary metric → progress affordance → primary action flanked by secondary controls. Useful precisely because it's not a fitness app — it isolates the idiom from domain noise.

**Borrow (idiom only):**
- **The whole hierarchy maps 1:1 to WorkoutCommandCard:**
  - Top chrome (collapse + context title + ellipsis) ↔ Unit's toolbar (close + workout title + actions)
  - Hero metadata (track name + artist) ↔ Unit's metric hero (weight × reps)
  - Linear progress bar with timestamps ↔ Unit's `SetProgressIndicator`
  - **Big circular primary action** centered (play/pause) ↔ Unit's "Complete set" CTA
  - **Secondary controls flanking the primary symmetrically** (prev / play / next) ↔ Unit's `RestTimerControl` (decrease / toggle / increase)
  - The fact that Spotify ships this exact symmetric-flanking layout *for the world's most-used media controls* validates the timer-control symmetry in Unit's design.
- **Timestamps below the progress bar**: left = elapsed, right = remaining (often negative). Universal "where you are vs where you're going" idiom. Unit's set-progress doesn't currently show time, but if it ever does, this is the placement.
- **Track-row mini-art + title + artist + trailing actions** is the canonical "now-acting-on-this" row. Maps to Unit's "current exercise" row in the lineup sheet (`exerciseLineupRowContent`) — small leading affordance + name + secondary text + trailing state indicator.

**Do NOT borrow:**
- ❌ **The dark gradient backdrop** (sourced from album art). Unit is paper-cream / off-white. Re-derive every color decision in light mode.
- ❌ **The "X" (don't recommend) and "+" (save)** chips on the track row. Recommendation/social affordance — banned by scope fence.
- ❌ **Connect / share / lyrics row** at the bottom. Sharing — banned.
- ❌ **Album art occupying ~40% of the screen.** Unit's WorkoutCommandCard is data-first; no hero imagery.
- ❌ **The shuffle / repeat icons** on the outer flanks. Unit's RestTimerControl flanks are decrease/increase — not mode toggles. Don't introduce parallel "repeat the set" or "shuffle exercises" affordances.
- ❌ **Spotify's icon weights** (medium-thin, white). Unit uses `AppIcon.image(weight: .semibold)` consistently — keep that.
