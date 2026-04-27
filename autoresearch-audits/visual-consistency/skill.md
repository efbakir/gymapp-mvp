# visual-consistency — v0

> Iterated file for the visual-consistency skill. Agent edits this to sharpen detection of design-system drift. Equivalent to `train.py` in autoresearch.
>
> Scope: design-system violations per `CLAUDE.md §5`, `docs/atomic-design-system.md`, `docs/visual-language.md`. Not crashes. Not dead ends. If it's a runtime issue, that belongs to `bug-hunter`. If it's a navigation problem, that belongs to `missing-flows`.

---

## Read these once per session (mandatory context)

- `CLAUDE.md` §5 (full Design System rules + Banned list + Parallel-implementation ban)
- `Unit/UI/DesignSystem.swift` — the **only** place raw values are allowed. Know what atoms/molecules exist before filing "parallel impl" findings.
- `docs/atomic-design-system.md`
- `docs/visual-language.md`

You may also read `DESIGN_SYSTEM.md` as an entry point.

---

## What to look for (v0 rules)

Each bullet gives the `rule` slug. Use it verbatim.

### Banned tokens in view code (severity: major if in `Unit/Features/**`, minor elsewhere)

Per `CLAUDE.md §5 Banned in view code`:

- **`banned-hex-literal`** — `Color(hex:...)`, `Color(red:green:blue:)`, `#(?:0x)?[0-9A-Fa-f]{6,8}` used as color outside `DesignSystem.swift`.
- **`banned-raw-color`** — `Color.black|Color.white|Color.gray|Color.red|Color.green|Color.blue` anywhere in `Unit/Features/**/*.swift` or `Unit/UI/Screens/**`. `Color.primary` and `Color.semantic` are allowed.
- **`banned-foregroundstyle-gray`** — `.foregroundStyle(.gray)` or `.foregroundColor(.gray)`.
- **`banned-raw-font-system`** — `.font(.system(size: ...))` where an `AppFont.*` token exists.
- **`banned-raw-font-primitive`** — `.font(.body)|.font(.caption)|.font(.title)` etc. where an `AppFont.*` would apply.
- **`banned-hardcoded-padding`** — numeric literal in `.padding(16)`, `.padding(.horizontal, 20)` — use `AppSpacing.*`.
- **`banned-hardcoded-radius`** — `.cornerRadius(12)`, `RoundedRectangle(cornerRadius: 8)` — use `AppRadius.*`.
- **`banned-chevron-right`** — `Image(systemName: "chevron.right"|"chevron.forward")`. Banned per `CLAUDE.md §5`.
- **`banned-divider-raw`** — `Divider()` where `AppDivider` is the convention.
- **`banned-regular-font-weight`** — `.fontWeight(.regular)`, `.weight(.regular)`. Default system weight is required.
- **`banned-orange-accent`** — hex `FF4400` or equivalent orange triples `(1.0, 0.27, 0.0)`. Replaced by `0x0A0A0A`.
- **`banned-preferredcolorscheme-dark`** — `.preferredColorScheme(.dark)` or dark-mode-first branching (`if colorScheme == .dark { ... styling }`).
- **`banned-scrolledgeeffect-hard`** — `.scrollEdgeEffectStyle(.automatic, ...)` or `.hard`. Must route through `appScrollEdgeSoft(top:bottom:)`.
- **`banned-lineargradient-fade`** — `LinearGradient` / `.mask` used as a fade behind a fixed top/bottom bar in `Unit/Features/**/*.swift`. Use `appScrollEdgeSoft` only.
- **`banned-toolbar-weight`** — `.fontWeight(.semibold|.bold|.heavy)` on a `ToolbarItem` button. iOS-native weight only.
- **`banned-accentsoft-add`** — `AppSecondaryButton(tone: .accentSoft, icon: .add, ...)` as a section "Add X" trigger. Use `AppGhostButton`.
- **`banned-sheet-scrollview-root`** — `.sheet { ScrollView { ... } }` or `.sheet { AppCard { ... } }` as the root child. Sheet roots should be plain `VStack` with `presentationDetents`.
- **`banned-unit-env-scaffold`** — `ProcessInfo.processInfo.environment["UNIT_*"]`, `UNIT_START_TAB`, `UNIT_AUTO_OPEN` left in `ContentView.swift` or any `Features/**/*.swift`. Temp scaffolding must be reverted before commit.
- **`banned-zero-kg-copy`** — string literal `"0 kg"` used as display copy for a bodyweight exercise. Use `"BW"` or `"No history yet"`.
- **`banned-endash-placeholder`** — `"–"` or `"—"` as placeholder copy in labels/values. Write the explicit string.

### Structural violations (severity: major)

- **`screen-not-appscreen`** — a top-level view (anything navigable as a tab destination or `NavigationLink` detail) is not wrapped in `AppScreen`. Grep `Unit/Features/**/*View.swift` for top-level `VStack`/`ScrollView` without `AppScreen`.
- **`cta-not-appprimarybutton`** — a primary/submit button uses inline styling (`.buttonStyle`, `.frame`, `.background`) instead of `AppPrimaryButton`. Particularly in onboarding, active workout, and template create/edit flows.
- **`card-not-appcard`** — a visible card container uses inline chrome (background + cornerRadius + shadow) instead of `AppCard` / `appCardStyle()`.
- **`touch-target-too-small`** — a tappable area's frame is < 44×44pt explicitly or by tight padding. Swift doesn't enforce this — manual review.

### Parallel-implementation violations (severity: critical — this is the #1 drift per `CLAUDE.md §5`)

These are worse than a raw hex literal because they bake drift into the design system itself.

- **`parallel-struct-view`** — a new `struct X: View` that duplicates or near-duplicates an existing atom/molecule in `DesignSystem.swift`. Example: `AppStackedCardList` when `AppDividedList(style:)` would have done it.
- **`parallel-viewmodifier`** — a new `ViewModifier` or `appFoo` helper duplicating an existing canonical one. Example: `appScrollEdgeSoftTop(enabled:)` where `appScrollEdgeSoft(top:bottom:)` is canonical.
- **`parallel-variant-token`** — a new hardcoded variant (color, spacing, radius) added inline in a feature file instead of a new token in `DesignSystem.swift`.
- **`parallel-inline-gradient-fade`** — inline `LinearGradient` behind a bar in a feature view when `appScrollEdgeSoft` exists.
- **`canonical-fork-not-migrated`** — `DesignSystem.swift` has been modified but callers still use the old helper. The canonical was updated without a caller migration.

To detect these: search for `^struct [A-Z][a-zA-Z0-9]*: View` outside `Unit/UI/DesignSystem.swift` and `Unit/UI/**`. For each match, open the file and judge whether the struct is genuinely new UI or a parallel of an existing atom. File only if it's a parallel.

### Polish violations (severity: minor)

- **`missing-tabular-numerals`** — weight/rep/time numeric displays that update frequently and should use `.monospacedDigit()` but don't. Active workout input fields are a prime suspect.
- **`inconsistent-corner-radius`** — two visible cards on the same screen using different radii when both should be `AppRadius.card`.
- **`inconsistent-spacing-rhythm`** — `.padding` values that vary by ±2pt between adjacent/sibling elements without a reason.
- **`image-outline-missing`** — `Image` with no `.clipShape` or `.overlay` outline where the design system expects one.

---

## How to run (v0 procedure)

### Pass 1 — grep sweep (fast, narrow)

For each banned-token rule, run a specific `Grep` call with the pattern below. Exclude `Unit/UI/DesignSystem.swift` (token source), `**/*Tests.swift`, and `*.md` docs. Examples:

| Rule                         | Pattern                                                           |
| ---------------------------- | ----------------------------------------------------------------- |
| `banned-hex-literal`         | `Color\(hex:\|Color\(red:\s*\d`                                   |
| `banned-raw-color`           | `Color\.(black\|white\|gray\|red\|green\|blue)\b`                 |
| `banned-foregroundstyle-gray`| `foregroundStyle\(\.gray\|foregroundColor\(\.gray`                |
| `banned-raw-font-system`     | `\.font\(\.system\(size:`                                         |
| `banned-hardcoded-padding`   | `\.padding\(\d`                                                   |
| `banned-hardcoded-radius`    | `cornerRadius:\s*\d\|\.cornerRadius\(\d`                          |
| `banned-chevron-right`       | `"chevron\.(right\|forward)"`                                     |
| `banned-divider-raw`         | `^\s*Divider\(\)` (excluding `AppDivider`)                        |
| `banned-sheet-scrollview-root`| `\.sheet\s*\{[^}]*ScrollView`                                    |
| `banned-unit-env-scaffold`   | `ProcessInfo\.processInfo\.environment\["UNIT_\|UNIT_START_TAB\|UNIT_AUTO_OPEN` |

Every match is a **candidate**. Read ±10 lines around it. If it's genuinely in view code and violates the rule, file.

### Pass 2 — parallel-impl structural review

This is the most important pass. Do not rush it.

1. Read `Unit/UI/DesignSystem.swift` in full.
2. List every `struct` that extends `View`, every `ViewModifier`, every `appFoo` helper. Keep this list in your head or in a scratch note during the iter.
3. Grep for `^struct [A-Z][a-zA-Z0-9]*: View` in `Unit/Features/**/*.swift` and `Unit/UI/Screens/**/*.swift`.
4. For each struct: does its purpose overlap with one in `DesignSystem.swift`? If yes → file `parallel-struct-view`.
5. Grep for new `struct .*: ViewModifier` outside `DesignSystem.swift`. Same question.
6. For `appScrollEdgeSoft`, `appCardStyle`, `AppPrimaryButton`, `AppGhostButton`, `AppDivider` specifically: grep for any **inline** re-implementation of the same effect. Common FP patterns are documented in `CLAUDE.md §5` — file those as specific named rules, not generic.

### Pass 3 — visual audit from screenshots

If simulator is bootable:

1. Reuse existing screenshots in `audit-screenshots/` if any from tonight's date. Do not re-screenshot if coverage is already good.
2. Otherwise capture: Today (empty + populated), Active Workout (1st set + mid-workout), Templates list, Template detail, History list, History calendar, Settings. Save as `audit-screenshots/visual-<iter>-<screen>.png`.
3. For each screenshot, check:
   - Corner radii consistent across sibling cards?
   - Spacing rhythm consistent?
   - No visible chevrons?
   - Touch targets look ≥ 44pt?
   - Typography hierarchy readable without reading any copy?
   - Light-mode correct (no dark-gray-on-black)?
4. File visual findings with `file = "—"`, `line = 0`, and a concrete screenshot path reference in the description.

---

## Confidence threshold

Before filing, ask:

1. **Can I quote the banned pattern and the rule number from `CLAUDE.md §5`?** If not → don't file.
2. **Is this in view code (`Unit/Features/**` or `Unit/UI/Screens/**`), not in `DesignSystem.swift` / tests / previews?** If not → don't file.
3. **For parallel-impl: can I name the canonical primitive that this is duplicating?** If not → don't file as parallel; maybe file as plain banned-token or skip.

---

## Candidate probes (draw from here when signal goes silent)

- **`sf-symbol-weight-drift`** — `Image(systemName:)` with a non-default weight (`.semibold`, `.bold`) scattered inconsistently across toolbars/buttons.
- **`navigationtitle-inconsistent-display-mode`** — screens mixing `.navigationBarTitleDisplayMode(.large)` and `.inline` without a clear convention.
- **`spacer-instead-of-spacing`** — `Spacer()` used for fixed-ish spacing where `AppSpacing.*` + fixed frame would be deterministic.
- **`button-label-sentence-case-drift`** — button labels mixing Title Case and sentence case inconsistently.
- **`opacity-instead-of-token`** — `.opacity(0.6)` for muted text where an `AppColor.textMuted` token would apply.
- **`animation-duration-hardcoded`** — `.animation(.easeInOut(duration: 0.2), ...)` where the DS specifies a duration token.

---

## What NOT to file (false-positive discipline)

- **Do not** flag `Color.primary` or `Color.accentColor` — those are semantic, allowed.
- **Do not** flag any violation inside `Unit/UI/DesignSystem.swift`. It's the token source — raw values live there by design.
- **Do not** flag `.padding()` (no argument) — that's semantic, the system applies defaults.
- **Do not** flag `Divider()` inside `DesignSystem.swift` or inside the definition of `AppDivider` itself.
- **Do not** flag `chevron.right` / raw colors / etc. inside `*.md` documentation, `*Tests.swift`, `#Preview { ... }` blocks, or `app/` (the marketing site — not the iOS app).
- **Do not** flag a new `struct X: View` in `Unit/Features/**` as `parallel-struct-view` unless you can name the canonical primitive it duplicates. A unique screen-level composition view is not a parallel.
- **Do not** flag a `ScrollView` inside `.sheet { ... }` if the sheet is long content that genuinely needs scrolling AND is inside an `AppScreen` or equivalent root wrapper. The ban is on `ScrollView` *as the sheet root*, not inside one.

When the human marks a finding `false_positive`, add a new exclusion here. Be specific — vague exclusions destroy the skill's coverage.
