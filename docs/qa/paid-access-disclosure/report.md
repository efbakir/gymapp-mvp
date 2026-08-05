# Visual verification — paid-access disclosure

**Claim:** The onboarding carousel shows the exact paid-access disclosure beneath `Set up your program` before setup begins, without clipping, overlap, an extra step, or an accessibility-order regression on the smallest supported iPhone and at Accessibility Medium.

**Build:** PASS — Debug UI automation and the Release simulator build both succeeded.

**Reference:** `docs/references/ios-screens/bevel__onboarding-fitness.png` for the quiet secondary-information hierarchy beneath a primary onboarding action; Unit's existing carousel remains the primary product reference.

## Primary screen

- Smallest supported iPhone: `01-smallest-iphone.png` (iPhone SE, 375 × 667 pt; 750 × 1334 px capture)
- Accessibility Medium: `02-accessibility-medium.png` (iPhone SE, 375 × 667 pt; 750 × 1334 px capture)

Observed:

- The exact disclosure is visible directly beneath the CTA in both states.
- The disclosure wraps to two lines at the compact size and three lines at Accessibility Medium without clipping or overlap.
- Secondary color and caption typography keep the setup CTA visually primary.
- UI automation confirms the CTA still opens `Choose weight unit` directly.
- UI automation confirms VoiceOver encounters the CTA before the disclosure.

**Verdict on claim:** VERIFIED.

## Sibling regression check

Not required. The change is confined to the onboarding carousel composition and reuses the existing primary button, caption typography, secondary color, and spacing tokens without changing a shared atom or molecule.

## Hard gates

| Gate | Result | Evidence |
|---|---|---|
| UI banned-list hook | PASS | Both changed production Swift files passed `.claude/hooks/ui-banned-list.sh`; the existing top-level `OnboardingSplashView` declaration produced only the expected reuse advisory. No new `View` type was added. |
| Interactive targets ≥ 44 × 44 pt | PASS | UI automation measured the carousel CTA at or above 44 pt in compact and Accessibility Medium states. The disclosure is non-interactive. |
| WCAG AA text contrast | PASS | `AppColor.textSecondary` (`#595959`) on `AppColor.background` (`#F5F5F5`) is 6.42:1. |
| Non-colour meaning and reduced motion | PASS | The disclosure communicates through text. The existing Reduce Motion guard remains in place; production auto-advance behavior is unchanged. |
| Gym Test | PASS | Active logging code is untouched. The full UI suite passed the first-session one-tap set test and the onboarding-to-logged-workout release gate. |
| No dead or misleading affordance | PASS | The disclosure renders as secondary static text; the single primary CTA remains actionable and routes directly to weight-unit selection. |
| Distinct states are not byte-identical | PASS | Compact SHA-256 `d0f698c66ce94c67356e1c193089aa8046d6b87ccc1541cf77568f0ab48dc5c0`; Accessibility Medium SHA-256 `aebc5c1527d48d97857adbeed3de5a97378874a03802535a92ebd9dd88ecc288`. `cmp` reports different files. |
| Light-only and portrait-only | PASS | Both screenshots are light portrait captures; the Release app plist retains `UIUserInterfaceStyle = Light` and portrait-only orientations. |

## Verification results

- 163 unit tests passed, 0 failed.
- 16 UI tests passed, 0 failed.
- Canonical English App Store metadata validation passed.
- Release simulator build passed as version 2.1, build 66.

## Reference comparison

- Match: one dominant onboarding action followed by quieter explanatory information.
- Intentional divergence: Unit uses its monochrome token system and direct paid-access copy rather than copying the reference's brand treatment.

## Conclusion

VERIFIED — the disclosure is visible, readable, accessible, and behaviorally inert in the simulator evidence for both required text-size states.
