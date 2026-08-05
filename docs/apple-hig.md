# Apple HIG Reference — Unit

Curated Human Interface Guidelines rules that directly govern Unit decisions.

| Rule | HIG Requirement | Unit Application |
|------|----------------|----------------------|
| **Touch Targets** | Minimum 44×44pt for all interactive elements | Set-row controls, recommendation edit actions, and tab bar items remain at least 44pt |
| **Tab Bar** | Maximum 5 items; tabs navigate only — never trigger actions | Current tabs navigate between app sections; no action-only tab items |
| **Typography** | Dynamic Type support and legible minimum sizes | New/refactored UI uses `AppFont` from `Unit/UI/DesignSystem.swift` |
| **Contrast** | 4.5:1 for normal text; 3:1 for large text (WCAG AA) | Verify primary and secondary text on `AppColor` page/card surfaces |
| **Color as sole indicator** | Never rely on color alone to convey meaning | Completed sets pair color with a checkmark/state; validation errors and recommendations use explanatory copy |
| **Appearance** | Respect system appearance where applicable | Light-first product baseline via `AppColor`; prefer tokens over hardcoded `.black` / `.white` in new UI |
| **Navigation** | `TabView` → `NavigationStack` → Sheets for modal tasks | Templates and History use navigation pushes; configuration and recommendation edits use sheets |
| **Motion** | Respect Reduce Motion preference | All animated transitions guarded with `@Environment(\.accessibilityReduceMotion)`. Toast uses `.opacity` when reduce motion is on, `.move + .opacity` otherwise |
| **VoiceOver** | All interactive elements need accessible labels; custom views need `.accessibilityValue` | Set rows expose set number, weight, reps, and completion; progression controls expose range and increment; charts expose metric values |
| **Sheets** | Use `.presentationDetents` to size sheets appropriately | Set/rep configuration and recommendation editing use the shared sheet patterns and appropriate detents |
| **Lists** | Minimum row height 44pt | All `SessionRow`, `SessionDetailView` rows: `frame(minHeight: 44)` |
| **Buttons** | Destructive actions require confirmation or a recoverable undo | Exercise removal offers Undo; larger destructive actions use confirmation dialogs |
| **Forms** | Use familiar grouped controls for structured data entry | Routine setup extends the shared set-and-rep editor rather than adding a parallel form |
| **Charts** | Use Charts framework (no third-party) | Exercise progress uses Swift Charts for weight, reps, and per-session volume |

---

## Contrast checks (light baseline)

- **Primary CTA**: `AppPrimaryButton` uses accent fill + white label — verify ≥ 4.5:1 for the label on the accent background.
- **Body text**: `AppColor.textPrimary` on `AppColor.background` / `AppColor.cardBackground` should meet WCAG AA for workout flows.
- **Secondary text**: `AppColor.textSecondary` on page/card surfaces — verify readability in bright gym lighting.
- **Failure / error**: system red tones from `AppColor.error` — pair with icon + copy, not color alone.

---

## Notes

- Never gate a11y behind a toggle — all accessibility attributes are always present
- `accessibilityHidden(true)` used only for decorative icons that are already described by adjacent text
- `accessibilityElement(children: .combine)` used on multi-element rows so VoiceOver reads them as a single unit
