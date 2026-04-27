# Logging screen and scroll polish (living plan)

## 1. Adjust result bottom sheet — weight / reps / note

**File:** [`Unit/Features/Today/ActiveWorkoutView.swift`](Unit/Features/Today/ActiveWorkoutView.swift) (`AdjustResultSheet`)

- Wrap the reps + weight row (and optional note) in **`AppCard(contentInset: AppSpacing.md)`** again, matching the earlier card-on-sheet layout.
- Keep **reps before weight** order.

### BW (bodyweight) as explicit selectable state

- Today, **BW** can appear as a **suffix** inside the weight field when `effectiveIsBodyweight` is inferred from typing `0` etc.
- **New behavior:** expose **BW as its own selectable control** (e.g. toggle, segmented control, or tappable chip/pill — reuse existing patterns like `AppSegmentedControl` / toggle rows elsewhere if present).
- When **BW is selected / ON:**
  - **Freeze** the weight numeric area: disable editing, fixed display (e.g. show **BW** or **0** as read-only), no keyboard for weight.
  - Saving still treats weight as bodyweight (0 or sentinel consistent with existing `completeSet` / `onSave` contract).
- When **BW is OFF:** weight field behaves as today (decimal pad, kg label as applicable).
- For exercises that are **always** bodyweight in the model (`isBodyweight == true`), BW can default **on** and stay frozen; for mixed exercises, user can toggle.

### Spacing

- Make **vertical gap between** the **reps+weight row** and the **optional note** field **equal** to the gap used **within** the card between other major blocks (use a single `AppSpacing` token, e.g. `AppSpacing.md`, consistently in that `VStack`).

### Disabled primary CTA (“Complete set”) — read more clearly inactive

**Context:** The sheet uses [`AppPrimaryButton`](Unit/UI/DesignSystem.swift) with `isEnabled: canSave`. Disabled state uses **`AppColor.textSecondary`** on **`AppColor.disabledSurface`**, which can still look too “active” (contrast too high).

**Goal:** **Lighter label color** when disabled so contrast drops and the control reads unmistakably as inactive.

**Implementation options (pick one when building):**

- **A (preferred if OK app-wide):** In `AppPrimaryButton`, when `!isEnabled`, use a more muted foreground than `textSecondary` — e.g. **`AppColor.secondaryLabel`**, or **`AppColor.textSecondary.opacity(0.55–0.65)`**, tuned against `disabledSurface`.
- **B (sheet-only):** Custom label styling / wrapper on **this** sheet’s button only, if we must not change global disabled primary buttons.

---

## 2. “Next” at bottom — full-width, centered

**Cause:** [`AppSecondaryButton`](Unit/UI/DesignSystem.swift) with `detail` left-aligns inner text.

**Fix:** Center-aligned variant or dedicated layout for [`SessionStateBar`](Unit/UI/DesignSystem.swift) next-exercise row (see prior plan).

---

## 3. Timer — `.ready` without capsule background; remove idle “Start rest” label

**File:** [`Unit/UI/DesignSystem.swift`](Unit/UI/DesignSystem.swift) — `RestTimerControl`

- No fill/stroke on center control when `state == .ready`; remove idle “Start rest” text block; refresh accessibility strings.

---

## 4. Set chips — completed sets with metrics: filled grey, not outline-only

**File:** [`Unit/UI/DesignSystem.swift`](Unit/UI/DesignSystem.swift) — `SetProgressIndicator`

- Replace outline capsule for completed+chipText with **`controlBackground` fill** and secondary text, aligned with upcoming grey circles.

---

## 5. Finish workout toolbar — checkmark only

**File:** [`Unit/Features/Today/ActiveWorkoutView.swift`](Unit/Features/Today/ActiveWorkoutView.swift)

- `checkmark` instead of `checkmark.circle` for finish icon.

---

## 6. Hierarchy — soften non-primary blacks on logging screen

Target `WorkoutCommandCard`, timer, toolbar, borders — keep one clear primary.

---

## 7. Navigation title — centered + truncated

**File:** [`Unit/Features/Today/ActiveWorkoutView.swift`](Unit/Features/Today/ActiveWorkoutView.swift)

- `ToolbarItem(placement: .principal)` + `lineLimit(1)` / truncation for long program names.

---

## 8. Scroll — system edge effects, not custom gradient stacks

- [`appScrollEdgeSoftTop`](Unit/UI/DesignSystem.swift): prefer **`.automatic`** over **`.soft`**.
- Remove **`ScrollEdgeFadeView`** stacks from [`AppScreen`](Unit/UI/DesignSystem.swift) where they duplicate system behavior.
- Align [`AppBottomSheetChromeModifier`](Unit/UI/DesignSystem.swift) and sheet call sites.

---

## Todos (tracked)

- [ ] AdjustResultSheet: AppCard + **BW selectable + freeze weight** + **even spacing to note** + **muted disabled Complete set text**
- [ ] Next-exercise CTA centered
- [ ] RestTimerControl ready + idle copy
- [ ] SetProgressIndicator filled chips
- [ ] Finish toolbar checkmark
- [ ] Hierarchy pass
- [ ] Principal nav title
- [ ] Scroll native edge effects
