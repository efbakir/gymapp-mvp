# Unit — Design system rules (full detail)

> Spillover from `CLAUDE.md` §4. Read this before any UI change. The CLAUDE.md inline summary is enough for routine edits; this file has the full banned-list with rationale, the parallel-implementation ban examples, and the full gatekeeper checklist.

---

## The 5 principles (apply to every UI decision)

1. **Keep it simple.** Default to removing, not adding. Fewer tokens, fewer variants, fewer words, fewer screens. If a change grows the system, justify it out loud before shipping.
2. **Reuse components. Do not create new ones.** Before writing any new `View`, grep `Unit/UI/DesignSystem.swift` and the existing molecules/organisms. If something ~80% fits — use it or extend it. Duplicates are worse than imperfect reuse. *Creating a parallel component is an explicit decision that requires the user's okay.*
3. **Light mode only.** No dark-mode styling, no `.preferredColorScheme(.dark)`, no dark-first visual decisions. Tokens may have dark values for system compatibility, but visual review and screenshots happen in light mode.
4. **Portrait only.** The app does not rotate. Landscape is not supported.
5. **Gatekeeper every UI change.** Run the checklist below before Edit/Write on any `.swift` view file. Fail-closed.

---

## Parallel-implementation ban (the #1 current drift)

The most frequent recent failure mode: Claude **invents a new struct / helper / modifier / variant when extending the existing canonical one would do.** This is worse than any hex literal, because it bakes drift into the design system itself.

### Concrete violations from recent sessions (do not repeat)

- Created `AppStackedCardList` instead of extending `AppDividedList` with a `style:` param.
- Kept an `appScrollEdgeSoftTop(enabled:)` helper using `.automatic` when the only correct value is `.soft` and both edges should be covered — canonical is `appScrollEdgeSoft(top:bottom:)`.
- Added `.font(...).weight(.semibold)` on `TodayView` toolbar buttons while every other view used iOS-native default weight.
- Reached for `AppSecondaryButton(tone: .accentSoft, icon: .add)` where `AppGhostButton` was the right atom.
- Wrapped `.sheet` content in `ScrollView { AppCard { ... } }` — sheets already provide chrome.
- Fixed a LinearGradient fade inline on a screen when the canonical `appScrollEdgeSoft` already existed.

### Rules

1. **Default: extend > create.** Before declaring any new `struct X: View` (or new `ViewModifier`, or new variant token) in `Unit/UI/DesignSystem.swift`, grep the file for the closest existing primitive. If one covers ~80%, extend it with a `style:` / `variant:` / `tone:` param. If you still want to create a new one, state the justification in one sentence. *No silent new primitives.*
2. **One canonical modifier per concern.** `scrollEdgeEffectStyle` lives behind `appScrollEdgeSoft(top:bottom:)`. Fades behind bars live behind the same modifier. Never add a parallel `LinearGradient` mask to a `Features/**/*.swift` view to achieve the same effect.
3. **Fix the canonical, migrate callers, don't fork.** If the canonical helper is wrong, update it and its callers in the same change. Do not leave the old one limping while the new one ships.
4. **Toolbar chrome defers to iOS-native.** No `.weight(.semibold/.bold/.heavy)` on `ToolbarItem` buttons unless every toolbar in the app uses the same weight.
5. **Sheet roots are plain `VStack`.** `.sheet { }` content does not need its own `ScrollView` + `AppCard` wrapper. Sheets have chrome.

Cross-reference: `feedback_unit_scroll_edge_soft.md` in memory.

---

## Gatekeeper checklist (run before every UI Edit/Write)

- [ ] I opened `Unit/UI/DesignSystem.swift` and checked whether an existing atom/molecule/organism already fits.
- [ ] **For any non-trivial UI change, I named the visual anchor from `docs/references/`** (which file in `ios-screens/` or `details/` this change borrows rhythm/hierarchy/density from). If no reference fits, I asked the user before inventing. (See `docs/references/README.md`.)
- [ ] **If this change introduces a new component / UI pattern / behavior not already in the design system, I cited a source of truth before the diff** — repo first (`PRODUCT.md`, `DESIGN.md`, `docs/product-compass.md`, `docs/atomic-design-system.md`, `docs/visual-language.md`, `docs/AGENTS.md`, `Unit/UI/DesignSystem.swift`), web second (Apple HIG, lawsofux, NN/g, growth.design). If neither covers it, I asked the user before proceeding.
- [ ] **I am not adding a new `struct X: View` or new `ViewModifier` without a one-line justification** of why extending the nearest primitive wouldn't work.
- [ ] **I am not adding a parallel `LinearGradient` / `.mask` / `.scrollEdgeEffectStyle(.automatic, ...)`** when `appScrollEdgeSoft(...)` is the canonical modifier.
- [ ] The change introduces no new raw colors, fonts, spacings, or radii — only tokens.
- [ ] The change adds no net-new component without the user's explicit okay.
- [ ] The change is light-mode correct. No dark-mode-first decisions.
- [ ] The change does not assume landscape or rotated layout.
- [ ] If this is a bug fix, I confirmed whether the bug is at the atom/molecule layer. **If yes, I fix only `DesignSystem.swift` — not also the feature file.** (See `CLAUDE.md` §5.)
- [ ] If I edited a `ToolbarItem` button, I did not add `.weight(...)` unless I'm changing the convention app-wide in the same turn.
- [ ] If I edited `.sheet { }` content, the root is a plain `VStack` (no `ScrollView` / `AppCard` wrapper). Use `presentationDetents` for height.
- [ ] The screen is wrapped in `AppScreen`. All CTAs use `AppPrimaryButton`. Cards use `AppCard` / `appCardStyle()`. No `chevron.right`. No `Divider()` where `AppDivider` applies.
- [ ] Touch targets ≥ 44×44pt. No regular font weight. No orange `#FF4400` (accent is `0x0A0A0A`).
- [ ] Copy is explicit, not a `–` / `—` placeholder. Bodyweight shows "BW", not "0 kg".
- [ ] No `ProcessInfo.processInfo.environment["UNIT_*"]` / `UNIT_START_TAB` / `UNIT_AUTO_OPEN` screenshot-scaffolding left in `ContentView.swift` or any `Features/**/*.swift`. Revert temp scaffolding before turn end.

---

## Banned in view code (full list with rationale)

The hook (`.claude/hooks/ui-banned-list.sh`) enforces a subset of these mechanically. The rest are conventions Claude must enforce itself.

### Tokens, not raw values

- Hex literals, `Color(red:green:blue:)`, `Color.black/.white/.gray/.red/.green/.blue/.primary/.secondary`
- `.foregroundStyle(.gray)` / `.foregroundColor(.gray)`
- `.font(.system(size:...))`, raw `.font(.body/.caption/.title)` where an `AppFont.*` applies
- Hardcoded paddings (`.padding(16)`, `.padding(.horizontal, 20)`) — use `AppSpacing.*`
- Hardcoded corner radii — use `AppRadius.*`
- `regular` font weight
- Orange accent `#FF4400` (replaced by darkest black `0x0A0A0A`)

### Components, not inline chrome

- `chevron.right` / `chevron.forward`
- `Divider()` where `AppDivider` is required
- Inline button styling for primary CTAs — use `AppPrimaryButton`
- Inline card chrome — use `AppCard` / `appCardStyle()`
- Screens not wrapped in `AppScreen`
- `AppSecondaryButton(tone: .accentSoft, icon: .add, ...)` as a section "Add X" trigger — use `AppGhostButton`

### Canonical modifiers, not parallel implementations

- `.scrollEdgeEffectStyle(.automatic, ...)` or `.hard` — always `.soft`, and route through `appScrollEdgeSoft(top:bottom:)`, never inline
- `LinearGradient` / `.mask` used as a fade under a fixed bar in `Features/**/*.swift` — use `appScrollEdgeSoft` only
- `.font(...).weight(.semibold/.bold/.heavy)` on `ToolbarItem` buttons — iOS-native default weight
- `ScrollView` or `AppCard` as the **root** child of `.sheet { }` — use plain `VStack` with `presentationDetents`
- Any new `struct X: View` / new `ViewModifier` / new variant added to `Unit/UI/DesignSystem.swift` **without an explicit one-line justification**

### Card composition

- `AppCard(contentInset: 0)` outside `Unit/UI/DesignSystem.swift` — produces 16pt text-from-edge instead of the canonical 24pt and collapses vertical inset to 0. The docstring reserves 0 for full-bleed media only. **Use `AppCardList` for any list-in-card surface.** Hook blocks this.
- `AppCard { … AppDividedList(…) … }` composed by hand outside `Unit/UI/DesignSystem.swift` — banned. **`AppCardList(data) { row }` is the canonical molecule** so card insets, divider insets, row horizontal padding, and row chrome cannot mismatch. Hook blocks this.

### Mode and orientation

- `.preferredColorScheme(.dark)` or any dark-mode-first styling decision
- Any landscape-only layout assumption

### Copy

- "0 kg" for bodyweight exercises (show "BW" or "No history yet")
- En-dash `–` / em-dash `—` as placeholder copy — write the explicit string

### Test scaffolding

- `ProcessInfo.processInfo.environment["UNIT_*"]` scaffolding committed in `ContentView.swift` or any `Features/**/*.swift` — test-only, must be reverted before turn end

---

## Single source of truth

`Unit/UI/DesignSystem.swift` is the **only** place raw values live. Every other file uses tokens. No exceptions without the user's explicit override.

**Prefer iOS-native over custom**: bottom sheets, tab bar chrome, buttons, arrows, navigation. Custom chrome only when system primitives genuinely can't express the design.
