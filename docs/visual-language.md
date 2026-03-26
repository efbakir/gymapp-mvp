# Unit — Visual language

**Light-first, calm, performance-focused.** The UI is built with the **atomic design system** (`atomic-design-system.md`): tokens live in `AppAtoms.swift`, screens compose through `AppScreen` and shared molecules/organisms.

**Core test:** Can a tired user read the screen and log a set in under 3 seconds?

---

## 1. Color

### Surfaces (light baseline)

- **Page background** (`AppColor.background`): Milk `#EBEBEB` — calm, neutral, and softer than pure white.
- **Elevated / nav surface** (`AppColor.surface`): White `#F6F6F6`.
- **Card surface** (`AppColor.cardBackground`): White `#F6F6F6` — cards separate from the page through **fill contrast**, not shadows.

### Text

- **Primary** (`AppColor.textPrimary`): Black `#0A0A0A` for body, titles, and key data.
- **Secondary / muted** (`AppColor.textSecondary`, `AppColor.mutedText`): `#919191` and `#646464` for labels, subtitles, and helper copy.

### Accent and primary CTA

- **Interactive accent** (`AppColor.accent`): Black `#0A0A0A` for primary actions. Restrained: **one obvious primary action** per screen where the Gym Test applies.
- **Accent soft** (`AppColor.accentSoft`): Milk `#EBEBEB` for subtle fills and iOS-style utility controls.

### Supporting

- **Borders** (`AppColor.border`): Hairlines and `AppDivider` — use sparingly.
- **Success / warning / error** (`AppColor.success`, `warning`, `error`): `#34C759`, system warning, and `#FF3B30`; pair with icons or labels — never color alone (HIG).

---

## 2. Design system size (hard constraint)

Keep the token set **small**. New roles need a Gym Test or clarity justification.

| Role | Guidance |
|------|-----------|
| Background levels | page / surface / card (as defined in atoms) |
| Text levels | primary / secondary / muted |
| Primary CTA | one dominant action per critical screen |
| Card treatment | prefer `AppCard` / `appCardStyle()` only |

---

## 3. Typography

- **Hierarchy**: Weight, reps, timers, and targets dominate. Exercise names and metadata are secondary.
- **Font**: System (San Francisco). Use **`AppFont`** cases from atoms — Dynamic Type–friendly paths should stay available as you refine screens.
- **Rule**: If text doesn’t help log or understand state, remove or demote it.

---

## 4. Layout and structure

- **Cards**: Rounded rectangle (`AppRadius.card` = 20) with iOS continuous corners, padding `AppSpacing.md`. Separation from background is **contrast**, not drop shadows.
- **One primary CTA** on high-stress flows: full-width black (accent) button pattern via `AppPrimaryButton` unless a documented exception exists.
- **Compact controls and buttons**: `AppRadius.md` = 12 with iOS continuous corners.
- **Spacing**: 4pt grid via `AppSpacing` — consistent section gaps vs. tight in-card grouping.
- **Navigation**: Root/product screens use `ProductTopBar`; detail flows can remain on `AppScreen` + shared nav molecules. Touch targets stay ≥ 44×44pt.

---

## 5. Components and patterns

- **Set logging**: Large tap targets, defaults from last session, minimal steps (Gym Test).
- **Command panels**: Active session screens should collapse around one dominant `WorkoutCommandCard` and one bottom `SessionStateBar`, not multiple competing cards.
- **Weekly progress**: Today uses `WeeklyProgressStepper` for cycle-week completion/miss/current/upcoming state. Logging uses set progress, not cycle-week progress.
- **Preview rails**: Day previews use `ExercisePreviewStrip` with horizontal scroll and trailing fade cue when overflow exists.
- **Success feedback**: Clear completion state (checkmark, row styling) — no “did it save?” ambiguity.
- **Sheets**: Focused sub-tasks; keep users in context.
- **Simple chrome**: `ProductTopBarAction` and `UnitTabBar` are custom product chrome, but interactions still follow native iOS expectations.
- **RIR / effort**: Steppers or capsules ≥ 44pt where used; failure state visually distinct + labeled.

---

## 6. Iconography

- **SF Symbols** only; weights/sizes set explicitly (`AppIcon` + `.image(size:weight:)`).
- Passive icons: secondary text color. Active / primary: accent or primary text as appropriate.

---

## 7. Rest timer and Live Activity

- **In-app**: Large, legible countdown; state obvious at a glance.
- **Pattern**: Use `RestTimerControl` inside `SessionStateBar`; avoid standalone giant timer cards or icon-only pause/play ambiguity.
- **Live Activity**: Lock Screen / Dynamic Island — same hierarchy principles; no decorative clutter.

---

## 8. Root shell

- **Tabs**: Root navigation uses `UnitTabBar`, not native UITabBar visuals.
- **Active state**: Active tab gets a filled muted surface; inactive tabs remain clear and legible.
- **Behavior**: Keep `TabView` for state and navigation preservation; custom tab bar owns appearance.

---

## 9. What we are not doing

- No gratuitous gradients, glows, or decorative illustration in core flows
- No shadow stacks to “lift” cards — rely on surface tokens
- No unbounded one-off components in page files — extend atoms/molecules/organisms first
- No native UITabBar chrome on root screens
- No floating text-only header actions without a clear tap container
- No spreadsheet-style logging layouts with parallel target/actual tables on critical set-entry screens
- No premature “Next exercise” CTA while the current exercise still owns the primary action

---

## Summary

| Element | Rule |
|---------|------|
| Background | Neutral grey page; white cards/surfaces via atoms |
| Cards | `AppCard` / `appCardStyle`; contrast, not shadows |
| Accent | Tokenized; one clear primary CTA on stress screens |
| Typography | Numbers and targets first; use `AppFont` |
| Structure | Atomic layers + `AppScreen` for new work |
| Benchmark | Gym Test + clarity under fatigue |

This visual language works with **`docs/atomic-design-system.md`** and the files under `Unit/UI/`.
