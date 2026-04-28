//
//  DesignSystem.swift
//  Unit
//
//  Shared UI atoms, molecules, organisms, and screen wrapper.
//

import SwiftUI
import UIKit

// MARK: - Atoms

/// Role-based color tokens. Every color used in the app resolves to a case here —
/// no `Color.black/.gray`, no raw hex literals in page files. **Light-mode only**
/// per CLAUDE.md §4 rule 3 — no dark-mode variants are maintained.
enum AppColor {
    // Surfaces
    static let background = Color(uiColor: uicolor(0xF5F5F5))
    static let cardBackground = Color(uiColor: uicolor(0xFFFFFF))
    /// Soft inset fill for elements nested inside `AppCard` (exercise rows, chips, inline cells).
    /// Matches page background so rows read as quiet recesses on white. Use with `AppRadius.sm` (10) +
    /// `AppSpacing.sm` (8) padding per the Figma source of truth. Do not use for top-level controls.
    static let cardRowFill = Color(uiColor: uicolor(0xF5F5F5))
    static let sheetBackground = Color(uiColor: uicolor(0xFFFFFF))
    /// Neutral surface for steppers, segmented track, disabled buttons, muted chip fills.
    /// Single canonical "secondary surface" token.
    static let controlBackground = Color(uiColor: uicolor(0xE8E8E8))

    // Text
    static let textPrimary = Color(uiColor: uicolor(0x0A0A0A))
    static let textSecondary = Color(uiColor: uicolor(0x595959))
    /// Disabled primary/secondary buttons — softer than `textSecondary` so inactive reads clearly.
    static let textDisabled = Color(uiColor: uicolor(0x949494))
    static let border = Color(uiColor: uicolor(0xE5E5E5))

    /// Filled segment in multi-step progress (e.g. onboarding) — softer than `textPrimary` but reads clearly against `border` for inactive steps.
    static let progressSegmentFill = Color(uiColor: uicolor(0x3A3A3A))

    // Interactive
    static let accent = Color(uiColor: uicolor(0x0A0A0A))
    static let accentForeground = Color(uiColor: uicolor(0xF6F6F6))
    static let accentSoft = Color(uiColor: uicolor(0xEBEBEB))

    // Status
    static let success = Color(uiColor: uicolor(0x34C759))
    static let warning = Color(uiColor: uicolor(0xFF9500))
    static let error = Color(uiColor: uicolor(0xFF3B30))

    /// Soft tint fills for status surfaces (calendar day cells, status badges).
    /// Replaces scattered `AppColor.success.opacity(0.18)` and peers.
    static let successSoft = success.opacity(0.18)
    static let warningSoft = warning.opacity(0.22)
    static let errorSoft = error.opacity(0.18)

    /// Accessible text colors paired with the matching `*Soft` backgrounds.
    /// Vivid `success` / `warning` fail WCAG AA contrast when set as text on their own
    /// soft tint; these darker shades are the chip foreground.
    static let successOnSoft = Color(uiColor: uicolor(0x1D7A38))
    static let warningOnSoft = Color(uiColor: uicolor(0x8A4A00))
    static let errorOnSoft = Color(uiColor: uicolor(0xB3261E))

    private nonisolated static func uicolor(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255,
            blue: CGFloat(hex & 0x0000FF) / 255,
            alpha: 1
        )
    }
}

/// Bundled custom font helpers. PostScript names match the .ttf filenames in
/// `Unit/Resources/Fonts/`. Use these only via `AppFont`; do not call from
/// feature code.
extension Font {
    /// Weight subset we ship — Geist is bundled as Medium / SemiBold / Bold only.
    enum AppWeight {
        case medium, semibold, bold
        var suffix: String {
            switch self {
            case .medium:   return "Medium"
            case .semibold: return "SemiBold"
            case .bold:     return "Bold"
            }
        }
    }

    static func geist(_ weight: AppWeight, size: CGFloat) -> Font {
        .custom("Geist-\(weight.suffix)", size: size)
    }

    static func geistMono(_ weight: AppWeight, size: CGFloat) -> Font {
        .custom("GeistMono-\(weight.suffix)", size: size)
    }
}

/// Typography tokens. Every font lives as an enum case so its associated
/// tracking is bundled with it — call sites apply both at once via
/// `.appFont(.X)` (Text) or `.font(AppFont.X.font)` + `.tracking(AppFont.X.tracking)`
/// (other views). Sans is **Geist**; numeric/CTA cases use **Geist Mono** for
/// fixed-width digits under fatigue. Minimum weight across the app is **medium**
/// (500) — never `.regular`. PostScript names match the bundled .ttf filenames.
enum AppFont {
    // Body hierarchy
    case largeTitle
    case title
    case sectionHeader
    case body
    case caption
    case muted

    // Display / specialized — previously loose `static let`s, now first-class cases
    /// 10pt semibold — top-of-card overline labels.
    case overline
    /// 11pt medium with +1.0 tracking — tiny uppercase "WAS" / "MOST POPULAR" style labels.
    case smallLabel
    /// 56pt bold — splash welcome title only.
    case splashTitle
    /// 16pt medium — splash welcome eyebrow / tagline pair.
    case splashWelcome
    /// 36pt mono bold — workout metric hero, big numerics.
    case numericDisplay
    /// 14pt mono semibold — set step counters in `SetProgressIndicator`.
    case stepIndicator
    /// 24pt bold — product-screen heading on `ProductTopBar`, hero copy on empty states.
    case productHeading
    /// 17pt mono bold — primary CTA labels, top-bar text actions.
    case productAction
    /// 15pt mono semibold — set-result / PR rows in History.
    case performance

    var font: Font {
        switch self {
        case .largeTitle:     return .geist(.bold,     size: 22)
        case .title:          return .geist(.bold,     size: 20)
        case .sectionHeader:  return .geist(.bold,     size: 17)
        case .body:           return .geist(.medium,   size: 17)
        case .caption:        return .geist(.medium,   size: 15)
        case .muted:          return .geist(.medium,   size: 13)
        case .overline:       return .geist(.semibold, size: 10)
        case .smallLabel:     return .geist(.medium,   size: 11)
        case .splashTitle:    return .geist(.bold,     size: 56)
        case .splashWelcome:  return .geist(.medium,   size: 16)
        case .productHeading: return .geist(.bold,     size: 24)
        case .numericDisplay: return .geistMono(.bold,     size: 36)
        case .stepIndicator:  return .geistMono(.semibold, size: 14)
        case .productAction:  return .geistMono(.bold,     size: 17)
        case .performance:    return .geistMono(.semibold, size: 15)
        }
    }

    var color: Color {
        switch self {
        case .muted: return AppColor.textSecondary
        default:     return AppColor.textPrimary
        }
    }

    /// Tracking baked into the case — apply via `.appFont(.X)` on Text and it lands automatically.
    /// Call sites should never pull a loose tracking constant from elsewhere.
    var tracking: CGFloat {
        switch self {
        case .largeTitle:     return -0.4
        case .splashTitle:    return -1.2
        case .productHeading: return -0.4
        case .numericDisplay: return -0.6
        case .smallLabel:     return 1.0    // uppercase-caps spacing
        default:              return 0
        }
    }
}

extension Text {
    /// Applies an AppFont style with its associated tracking.
    func appFont(_ style: AppFont) -> Text {
        self.font(style.font).tracking(style.tracking)
    }
}


/// 4pt-grid spacing tokens. Use instead of `.padding(16)` / literal gaps so section
/// rhythm stays consistent. `smd` (12) fills the gap between `sm` and `md` for
/// compact controls; `xxl` (48) for rare top-of-screen gutters.
enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32

    static let smd: CGFloat = 12
    static let xxl: CGFloat = 48
}

/// Corner radius tokens, all used with `RoundedRectangle(style: .continuous)`.
/// `sm` compact chips/cells, `md` buttons + inputs, `lg` (`card`) cards.
/// No other radii should appear in page code.
enum AppRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    /// Card outer radius. Concentric-radius math holds for `AppCardList` rows
    /// (card 22 − row inset 12 = row pill 10 = `sm`) and for any inline button
    /// (card 22 − button inset 8 = button radius 14 = `md`). Default `AppCard`
    /// content inset is `lg` (24), where concentric math doesn't apply because
    /// content is plain text/buttons rather than nested radii.
    static let lg: CGFloat = 22
    /// Semantic alias — prefer `card` at call sites where the radius is a card's
    /// outer corner (the docs and visual-language.md both reference `AppRadius.card`).
    static let card: CGFloat = lg

    /// Corner radius for a square tile so `RoundedRectangle(..., style: .continuous)` matches the iPhone Home Screen app icon mask (Apple icon grid: `10/57 × side length`).
    static func appIconHomeScreenCornerRadius(sideLength: CGFloat) -> CGFloat {
        sideLength * 10 / 57
    }

    /// Splash welcome logo tile — smaller radius than the Home Screen icon mask for a slightly squarer tile.
    static func splashLogoTileCornerRadius(sideLength: CGFloat) -> CGFloat {
        appIconHomeScreenCornerRadius(sideLength: sideLength) * 0.68
    }
}

/// Shared sizing for day/week steppers and compact day badges (Paper e.g. node 2P1-0).
enum AppProgressChipMetrics {
    static let rowHeight: CGFloat = 20
    static var compactHorizontalPadding: CGFloat { AppSpacing.sm }
}

/// Motion tokens. The single source of truth for every duration, curve, and spring
/// in the app. Page files call `.appPress` / `.appState` / etc. — never raw
/// `.easeInOut(duration:)` literals.
///
/// Doctrine, restated for the next reader:
/// - **State only.** Motion conveys feedback, reveal, transition between views.
///   Decorative motion is banned in the hot loop (PRODUCT.md, DESIGN.md §4).
/// - **Ease-out only.** No bounce, no elastic, no overshoot. Users are mid-set.
/// - **≤ 320 ms.** The product register cap. Anything longer reads as laggy.
/// - **Exit ≈ 75 % of enter.** Symmetry between dismissal and presentation reads
///   wrong on touch devices — exits should feel decisive.
///
/// Reduce Motion is a call-site contract: `reduceMotion ? nil : .appXxx`, or use
/// `.appAnimation(_:value:reduceMotion:)`. There is no global wrapper because
/// every surface needs to decide its own fallback (sometimes nil, sometimes a
/// shorter cross-fade). See `OnboardingSplashView` for the canonical pattern.
enum AppMotion {
    enum Duration {
        /// 150 ms — instant feedback (button press, toggle confirm). Matches `ScaleButtonStyle`.
        static let press: Double = 0.15
        /// 200 ms — state toggle (toast in/out, tier select, mode swap).
        static let state: Double = 0.20
        /// 250 ms — content reveal (text content swap, progress fill).
        static let reveal: Double = 0.25
        /// 320 ms — entrance (card / sheet appear, hero element).
        static let enter: Double = 0.32
        /// 180 ms — exit (~75 % of enter; dismissal is decisive).
        static let exit: Double = 0.18
    }

    /// Easing curves translated from the design-for-AI motion doctrine
    /// (cubic-bezier values are the same as `--ease-out-quart/quint/expo`).
    enum Curve {
        /// `cubic-bezier(0.25, 1, 0.5, 1)` — smooth, refined. Default for state changes.
        static func quart(_ duration: Double) -> Animation {
            .timingCurve(0.25, 1, 0.5, 1, duration: duration)
        }
        /// `cubic-bezier(0.22, 1, 0.36, 1)` — slightly snappier. Default for entrances.
        static func quint(_ duration: Double) -> Animation {
            .timingCurve(0.22, 1, 0.36, 1, duration: duration)
        }
        /// `cubic-bezier(0.16, 1, 0.3, 1)` — confident, decisive. Reserve for hero moments.
        static func expo(_ duration: Double) -> Animation {
            .timingCurve(0.16, 1, 0.3, 1, duration: duration)
        }
    }

    /// Confirmation spring (segmented pill, set-completed pulse). Damping ≥ 0.85
    /// keeps it brisk — anything looser reads as "bouncy" and is banned by doctrine.
    static let confirmSpring: Animation = .spring(response: 0.32, dampingFraction: 0.85)
}

extension Animation {
    /// 150 ms easeInOut — button press feedback. Ties `ScaleButtonStyle` to
    /// the token system; previously hardcoded.
    static let appPress: Animation = .easeInOut(duration: AppMotion.Duration.press)

    /// 200 ms ease-out-quart — state toggles (visibility, mode swaps, tier select).
    static let appState: Animation = AppMotion.Curve.quart(AppMotion.Duration.state)

    /// 250 ms ease-out-quart — content swap (numeric text, progress fills).
    static let appReveal: Animation = AppMotion.Curve.quart(AppMotion.Duration.reveal)

    /// 320 ms ease-out-quint — entrance (card appear, sheet present, hero land).
    static let appEnter: Animation = AppMotion.Curve.quint(AppMotion.Duration.enter)

    /// 180 ms ease-out-quart — exit (75 % of enter, decisive).
    static let appExit: Animation = AppMotion.Curve.quart(AppMotion.Duration.exit)

    /// Spring for confirmation pulses (segmented pill move, set logged). Same
    /// numbers the segmented pill already used; lifted so all confirm-class
    /// motion stays in lockstep.
    static let appConfirm: Animation = AppMotion.confirmSpring
}

extension View {
    /// `.animation(_:value:)` with a Reduce Motion gate baked in. Pass the
    /// environment's `accessibilityReduceMotion` value; the modifier resolves
    /// to `nil` when true, so the change still happens but instantly.
    func appAnimation<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        self.animation(reduceMotion ? nil : animation, value: value)
    }
}

/// Canonical row separator. 1pt hairline at `AppColor.border.opacity(0.55)` —
/// the same value the active-workout lineup hand-rolled before consolidation.
/// Used by `AppDividedList` (and a handful of card-row contexts that compose
/// rows by hand). Spans the full width of its container; constrain via
/// surrounding `.padding(.leading/.trailing, ...)` if a non-full-width inset is
/// needed.
struct AppDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.border.opacity(0.55))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

/// Shared card elevation — single hairline stroke. Per visual-language.md
/// §1, §4, §9, cards separate from the page through **fill contrast**, not
/// shadows. The stroke is the only chrome added here.
private struct AppCardElevation: ViewModifier {
    var cornerRadius: CGFloat = AppRadius.lg

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }
    }
}

/// Sheet-hosted input field chrome — no-op now that elevation is contrast-only.
/// Retained as a stable extension point if a future variant ever needs to lift
/// inputs (e.g. sheet stacking). Today it intentionally renders flat.
private struct AppInputElevation: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        content
    }
}

/// Workout logging surface — same chrome as `AppCardElevation`: fill + stroke.
/// `AppCard` is the canonical card; this exists only because the workout panel
/// composes its own internal layout (hairline divider between metric and timer)
/// and can't pass through `AppCard`'s VStack-of-content pattern.
private struct AppWorkoutPanelChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }
    }
}

/// SF Symbol catalog as role-named cases. Always invoke via `.image(size:weight:)`
/// so icons across the app share the same stroke weight. `chevron.right` lives on
/// `.forward` for platform-symmetric back/forward pairs — but **do not** apply it
/// as a disclosure glyph on `AppListRow` content per the HIG + design-system rules.
enum AppIcon: String {
    case back = "chevron.left"
    case forward = "chevron.right"
    case chevronDown = "chevron.down"
    case close = "xmark"
    case add = "plus"
    case remove = "minus"
    case edit = "pencil"
    case trash = "trash"
    case swap = "arrow.triangle.2.circlepath"
    case search = "magnifyingglass"
    case program = "square.and.pencil"
    case todayTab = "dumbbell.fill"
    case settings = "gearshape.fill"
    case settingsOutline = "gearshape"
    case checkmarkFilled = "checkmark.circle.fill"
    case checkmark = "checkmark"
    case xmarkFilled = "xmark.circle.fill"
    case play = "play.fill"
    case pause = "pause.fill"
    case list = "list.bullet"
    case calendarClock = "calendar.badge.clock"
    case bolt = "bolt.fill"
    case chart = "chart.line.uptrend.xyaxis"
    case addCircle = "plus.circle.fill"
    case sliders = "slider.horizontal.3"
    case photo = "photo"
    case dumbbell = "dumbbell"
    case trophy = "trophy"
    case reorder = "line.3.horizontal"
    case camera = "camera"
    case clipboard = "doc.on.clipboard"
    case keyboard = "keyboard"
    case minusCircle = "minus.circle"
    case circle = "circle"
    case moveUp = "arrow.up"
    case moveDown = "arrow.down"
    case more = "ellipsis.circle"

    var systemName: String { rawValue }

    func image(size: CGFloat = 17, weight: Font.Weight = .semibold) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight, design: .rounded))
    }
}

extension Double {
    var weightString: String {
        self == floor(self) ? "\(Int(self))" : String(format: "%.1f", self)
    }
}

// MARK: - Molecules

/// Standard list row — optional leading icon, title, secondary subtitle, and a
/// trailing slot. **Chevron-free by design**: never add `.forward` as a disclosure
/// glyph; let context + tap target convey navigation (HIG).
/// Use `.tappable` (default) for interactive rows — gets 44pt minHeight and a
/// hit-testable content shape. Use `.display` for read-only catalog rows inside
/// a shared card — drops the 44pt floor and tightens vertical padding so dense
/// lists don't feel airy.
enum AppListRowStyle {
    case tappable
    case display
}

struct AppListRow<Trailing: View>: View {
    let title: String
    let subtitle: String?
    let leadingIcon: AppIcon?
    var style: AppListRowStyle = .tappable
    @ViewBuilder let trailing: () -> Trailing

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: AppIcon? = nil,
        style: AppListRowStyle = .tappable,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.style = style
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let leadingIcon {
                leadingIcon.image(size: 15, weight: .semibold)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFont.body.font)
                    .foregroundStyle(AppFont.body.color)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppFont.muted.font)
                        .foregroundStyle(AppFont.muted.color)
                }
            }

            Spacer(minLength: 0)

            trailing()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, style == .display ? AppSpacing.xs : AppSpacing.sm)
        .frame(minHeight: style == .display ? nil : 44, alignment: .leading)
        .contentShape(Rectangle())
    }
}

extension AppListRow where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: AppIcon? = nil,
        style: AppListRowStyle = .tappable
    ) {
        self.init(title: title, subtitle: subtitle, leadingIcon: leadingIcon, style: style) {
            EmptyView()
        }
    }
}

/// − / value / + stepper — compact rounded control with 44pt hit targets.
/// Used for set counts, rest-duration seconds, reps, etc. Value is a pre-formatted
/// string (monospaced digits) so callers own unit rendering ("12 reps" vs "12").
struct AppStepper: View {
    let value: String
    var minimumValueWidth: CGFloat = 28
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    /// Phase counters drive `.sensoryFeedback` so every ± tap fires a haptic
    /// without requiring callers to thread one through. `.increase` /
    /// `.decrease` are the iOS-native semantic pair (introduced iOS 17) that
    /// matches stepper interactions exactly.
    @State private var incrementPhase: Int = 0
    @State private var decrementPhase: Int = 0

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            stepButton(icon: .remove) {
                decrementPhase &+= 1
                onDecrement()
            }

            Text(value)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppFont.sectionHeader.color)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(minWidth: minimumValueWidth)
                .contentTransition(.numericText())
                .animation(.appReveal, value: value)

            stepButton(icon: .add) {
                incrementPhase &+= 1
                onIncrement()
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .sensoryFeedback(.increase, trigger: incrementPhase)
        .sensoryFeedback(.decrease, trigger: decrementPhase)
    }

    private func stepButton(icon: AppIcon, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon.image(size: 14, weight: .semibold)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
    }
}

/// Multi-line text input with a greyed-out placeholder shown when empty.
/// Canonical chrome for any free-form paragraph editor — never style a raw
/// `TextEditor` in a feature view. `TextField` already has native placeholder
/// support, so this atom exists specifically to give `TextEditor` parity.
///
/// Caller-applied modifiers (`.textInputAutocapitalization`, `.autocorrectionDisabled`,
/// `.focused`, etc.) propagate through the wrapper to the underlying `TextEditor`.
struct AppTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 220

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(AppFont.body.font)
                .foregroundStyle(AppColor.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(AppSpacing.md)

            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
                    // TextEditor's internal NSTextContainer inset is ~5pt horizontal,
                    // ~8pt vertical — offset the placeholder so it sits on the cursor.
                    .padding(.horizontal, AppSpacing.md + 5)
                    .padding(.top, AppSpacing.md + 8)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .appCardElevation()
    }
}

/// Full-width filled CTA — the **single** dominant action on any Gym-Test screen.
/// Use inside `AppScreen(primaryButton:)` for sticky bottom CTAs, or inline for
/// in-card primaries. Never more than one on screen in core logging flows.
struct AppPrimaryButton: View {
    let label: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    init(_ label: String, isEnabled: Bool = true, isLoading: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    private var isInteractive: Bool { isEnabled && !isLoading }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(label)
                    .font(AppFont.productAction.font)
                    .foregroundStyle(isEnabled ? AppColor.accentForeground : AppColor.textDisabled)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.9)
                    .padding(.horizontal, AppSpacing.md)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(AppColor.accentForeground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isEnabled ? AppColor.accent : AppColor.controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isInteractive)
        .accessibilityLabel(label)
        .accessibilityValue(isLoading ? Text("loading") : Text(""))
    }
}

/// Filled secondary action used **only** by active-workout organisms — the
/// `metricHero` "Log" pill in `WorkoutCommandCard` and the inline "Next exercise"
/// row in `SessionStateBar`. `fileprivate` so feature code cannot compose it:
/// page files use `AppPrimaryButton` (sticky CTA) or `AppGhostButton` (quiet action).
fileprivate struct AppSecondaryButton: View {
    enum Tone {
        case `default`
        case accentSoft
        case destructive
    }

    enum DetailAlignment {
        case leading
        case center
    }

    enum DetailLayout {
        case stacked
        case inline
    }

    let label: String
    var isEnabled: Bool = true
    var icon: AppIcon? = nil
    var detail: String? = nil
    var detailAlignment: DetailAlignment = .leading
    var detailLayout: DetailLayout = .stacked
    var tone: Tone = .default
    var fillsAvailableWidth: Bool = true
    let action: () -> Void

    init(
        _ label: String,
        isEnabled: Bool = true,
        icon: AppIcon? = nil,
        detail: String? = nil,
        detailAlignment: DetailAlignment = .leading,
        detailLayout: DetailLayout = .stacked,
        tone: Tone = .default,
        fillsAvailableWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isEnabled = isEnabled
        self.icon = icon
        self.detail = detail
        self.detailAlignment = detailAlignment
        self.detailLayout = detailLayout
        self.tone = tone
        self.fillsAvailableWidth = fillsAvailableWidth
        self.action = action
    }

    private var trimmedDetail: String? {
        guard let detail else { return nil }
        let t = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    var body: some View {
        Button(action: action) {
            Group {
                if let trimmedDetail {
                    if detailLayout == .inline {
                        inlineDetailRow(trimmedDetail: trimmedDetail)
                    } else if detailAlignment == .center {
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            Spacer(minLength: 0)
                            if let icon {
                                icon.image(size: 16, weight: .semibold)
                                    .foregroundStyle(foregroundColor)
                            }
                            VStack(alignment: .center, spacing: AppSpacing.xxs) {
                                Text(label)
                                    .font(AppFont.productAction.font)
                                    .foregroundStyle(foregroundColor)
                                Text(trimmedDetail)
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(isEnabled ? AppColor.textSecondary : AppColor.textDisabled)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer(minLength: 0)
                        }
                    } else {
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            if let icon {
                                icon.image(size: 16, weight: .semibold)
                                    .foregroundStyle(foregroundColor)
                            }
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text(label)
                                    .font(AppFont.productAction.font)
                                    .foregroundStyle(foregroundColor)
                                Text(trimmedDetail)
                                    .font(AppFont.caption.font)
                                    .foregroundStyle(isEnabled ? AppColor.textSecondary : AppColor.textDisabled)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else {
                    HStack(alignment: .center, spacing: AppSpacing.sm) {
                        if let icon {
                            icon.image(size: 16, weight: .semibold)
                                .foregroundStyle(foregroundColor)
                        }
                        Text(label)
                            .font(AppFont.productAction.font)
                            .foregroundStyle(foregroundColor)
                    }
                }
            }
            .padding(.horizontal, secondaryHorizontalPadding)
            .frame(maxWidth: fillsAvailableWidth ? .infinity : nil)
            .frame(height: 60)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }

    private var secondaryHorizontalPadding: CGFloat {
        if !fillsAvailableWidth {
            return AppSpacing.md
        }
        return trimmedDetail == nil ? 0 : AppSpacing.md
    }

    @ViewBuilder
    private func inlineDetailRow(trimmedDetail: String) -> some View {
        let detailColor = isEnabled ? AppColor.textSecondary : AppColor.textDisabled
        let row = HStack(alignment: .center, spacing: AppSpacing.smd) {
            if let icon {
                icon.image(size: 16, weight: .semibold)
                    .foregroundStyle(foregroundColor)
            }
            Text(label)
                .font(AppFont.productAction.font)
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
            Text(trimmedDetail)
                .font(AppFont.productAction.font)
                .foregroundStyle(detailColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        if detailAlignment == .center {
            HStack {
                Spacer(minLength: 0)
                row
                Spacer(minLength: 0)
            }
        } else {
            row
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return AppColor.textDisabled }
        switch tone {
        case .default: return AppColor.textPrimary
        case .accentSoft: return AppColor.accent
        case .destructive: return AppColor.error
        }
    }

    private var backgroundColor: Color {
        guard isEnabled else {
            return tone == .destructive ? Color.clear : AppColor.controlBackground.opacity(0.5)
        }
        switch tone {
        case .default: return AppColor.controlBackground
        case .accentSoft: return AppColor.controlBackground
        case .destructive: return Color.clear
        }
    }
}

/// Text-only action (no fill). Full-width row with **centered** label and ≥44pt hit area.
/// Use inside `NavigationLink` labels or with `AppGhostButton`.
struct AppGhostButtonLabel: View {
    let title: String
    var isEnabled: Bool = true

    var body: some View {
        Text(title)
            .font(AppFont.productAction.font)
            .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textDisabled)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}

/// Text-only quiet action (no fill, no stroke) — use for "Freestyle session",
/// "Skip", or any optional path that shouldn't compete with the primary CTA.
/// 44pt hit area. For disclosure link labels, use `AppGhostButtonLabel` directly.
struct AppGhostButton: View {
    let label: String
    var isEnabled: Bool = true
    let action: () -> Void

    init(_ label: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            AppGhostButtonLabel(title: label, isEnabled: isEnabled)
                .frame(height: 60)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

/// Static status/label pill — "Completed", "Up next", "Missed", "Day 3 of 5".
/// Use `.success` / `.warning` / `.error` for status; `.muted` / `.default` for
/// neutral labels; `.accent` to emphasize. For toggle-able filter pills, use
/// `AppFilterChip` — not this component.
struct AppTag: View {
    let text: String
    var style: Style = .default
    /// `.compactCapsule` matches Paper today “Day n of m” (node 2P1-0) — short status pills inside cards.
    var layout: Layout = .regular
    /// Optional leading glyph rendered inline with the text (same foreground color).
    var icon: AppIcon? = nil

    enum Layout {
        case regular
        case compactCapsule
    }

    enum Style {
        case `default`
        case accent
        case success
        case warning
        case error
        case muted
        case custom(fg: Color, bg: Color)
    }

    var body: some View {
        Group {
            switch layout {
            case .regular:
                content
                    .padding(.horizontal, AppSpacing.smd)
                    .padding(.vertical, AppSpacing.sm)
                    .background(backgroundColor)
                    .clipShape(Capsule())
            case .compactCapsule:
                content
                    .padding(.horizontal, AppProgressChipMetrics.compactHorizontalPadding)
                    .frame(height: AppProgressChipMetrics.rowHeight)
                    .background(backgroundColor)
                    .clipShape(Capsule())
            }
        }
    }

    private var content: some View {
        HStack(spacing: AppSpacing.xs) {
            if let icon {
                icon.image(size: 12, weight: .semibold)
            }
            Text(text)
                .font(AppFont.stepIndicator.font)
        }
        .foregroundStyle(foregroundColor)
    }

    private var foregroundColor: Color {
        switch style {
        case .default: return AppColor.textPrimary
        case .accent: return AppColor.accentForeground
        case .success: return AppColor.successOnSoft
        case .warning: return AppColor.warningOnSoft
        case .error: return AppColor.errorOnSoft
        case .muted: return AppColor.textSecondary
        case .custom(let fg, _): return fg
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return AppColor.controlBackground
        case .accent: return AppColor.accent
        case .success: return AppColor.successSoft
        case .warning: return AppColor.warningSoft
        case .error: return AppColor.errorSoft
        case .muted: return AppColor.controlBackground
        case .custom(_, let bg): return bg
        }
    }
}

/// Capsule dropdown chip — pairs a label with a trailing `chevron.down` and wraps
/// the provided menu `content` in an iOS-native `Menu`. Use when a filter has
/// more than ~3 mutually-exclusive values, where a row of `AppFilterChip` toggles
/// would overflow; the native menu gives automatic checkmarks and dismissal.
///
/// Justification vs. extending `AppFilterChip`: filter chips are binary toggles
/// (one action, one selected state). A dropdown chip renders N-option menus and
/// owns no action itself — conflating the two would muddy both APIs. Selection
/// styling (inverted fill when `isActive`) mirrors `AppFilterChip` so the two
/// atoms compose in the same row without visual drift.
struct AppDropdownChip<Content: View>: View {
    let label: String
    var isActive: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        Menu {
            content()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFont.caption.font)
                AppIcon.chevronDown.image(size: 10, weight: .bold)
            }
            .foregroundStyle(isActive ? AppColor.background : AppColor.textPrimary)
            .padding(.horizontal, AppSpacing.smd)
            .padding(.vertical, AppSpacing.xs)
            .background(
                Capsule()
                    .fill(isActive ? AppColor.textPrimary : AppColor.accentSoft)
            )
            // Visible capsule stays compact; hit zone extends to 44pt floor
            // so the chip rhythm reads the same as `AppFilterChip` next to it.
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

/// Toggleable capsule chip for filter bars (Exercises list, Program library, History)
/// and segmented pickers (onboarding day strip). Selected state inverts to
/// `textPrimary` fill with `background` foreground — the canonical "active pill"
/// recipe for Unit. Not for status labels — use `AppTag` there.
///
/// Two optional trailing affordances:
/// - `showsClearGlyphWhenSelected`: trailing `×` when selected, signals "tap to clear".
/// - `showsTrailingDot`: small status dot regardless of selection — used by the
///   onboarding day picker to flag days that still need exercises. Dot inverts
///   color in the selected state so it stays visible against the dark fill.
struct AppFilterChip: View {
    let label: String
    let isSelected: Bool
    /// Show an `×` to the right of the label when selected — used on History where
    /// tapping a selected chip clears the filter. Filter bars that reset via a
    /// dedicated "All" pill should leave this false.
    var showsClearGlyphWhenSelected: Bool = false
    /// Show a small status dot at the trailing edge regardless of selection state.
    /// Used by the onboarding day picker to flag days with no exercises yet.
    var showsTrailingDot: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFont.caption.font)
                if isSelected && showsClearGlyphWhenSelected {
                    AppIcon.close.image(size: 10, weight: .bold)
                }
                if showsTrailingDot {
                    Circle()
                        .fill(isSelected ? AppColor.background : AppColor.warning)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundStyle(isSelected ? AppColor.background : AppColor.textPrimary)
            .padding(.leading, AppSpacing.smd)
            .padding(.trailing, isSelected && showsClearGlyphWhenSelected ? AppSpacing.sm : AppSpacing.smd)
            .padding(.vertical, AppSpacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? AppColor.textPrimary : AppColor.accentSoft)
            )
            // Visible capsule stays compact; hit zone extends to 44pt floor
            // for one-handed reachability without changing the chip's rhythm.
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(
            showsClearGlyphWhenSelected && isSelected ? "Tap to clear filter" : "Tap to filter"
        )
    }
}

/// Canonical horizontal filter-chip strip — one `ScrollView(.horizontal)` with
/// `AppSpacing.xs` between chips and `appScrollEdgeSoft()` at the leading/trailing
/// edges so chips fade rather than sharp-cut. Use anywhere a row of
/// `AppFilterChip` toggles or `AppDropdownChip` menus needs to scroll
/// horizontally (Program library, Exercises list, History). Single source of
/// truth for chip-bar chrome — never re-roll a `ScrollView { HStack { chips } }`
/// inline in a feature view.
///
/// `contentInset` only adds horizontal padding to the chip strip itself.
/// Default `0` for bars hosted inside `AppScreen` (which already provides 16pt
/// outer padding via `paddedMainContent`). Pass `AppSpacing.md` (16pt) for bars
/// hosted in containers without outer padding (e.g. a `List` row with
/// `listRowInsets(EdgeInsets())`).
struct AppFilterChipBar<Content: View>: View {
    var contentInset: CGFloat = 0
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                content()
            }
            .padding(.horizontal, contentInset)
            .padding(.vertical, AppSpacing.xxs)
        }
        .appScrollEdgeSoft()
    }
}

/// Pill-shaped header action (48pt icon square or 60pt-min text label) used
/// inside `ProductTopBar`. The visible tap area replaces floating text headers
/// so every header action has a clear hit target.
private struct ProductTopBarAction: View {
    enum Content {
        case text(String)
        case icon(AppIcon)
    }

    let content: Content
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                switch content {
                case .text(let label):
                    Text(label)
                        .font(AppFont.productAction.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(minWidth: 60, minHeight: 48)

                case .icon(let icon):
                    icon.image(size: 16, weight: .semibold)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(AppColor.controlBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Root/product-screen top bar — title + optional leading/trailing actions on a
/// 64pt surface. Compose via `AppScreen(customHeader:)`. Detail flows use the
/// system `NavigationStack` chrome (`showsNativeNavigationBar: true`); this
/// replaces large-title chrome on root tabs and modal sheets.
struct ProductTopBar: View {
    enum Size {
        case md
        case large
    }

    struct ActionItem: Identifiable {
        enum Kind {
            case text(String)
            case icon(AppIcon)
        }

        let id = UUID()
        let kind: Kind
        let action: () -> Void

        static func text(_ label: String, action: @escaping () -> Void) -> ActionItem {
            ActionItem(kind: .text(label), action: action)
        }

        static func icon(_ icon: AppIcon, action: @escaping () -> Void) -> ActionItem {
            ActionItem(kind: .icon(icon), action: action)
        }
    }

    let title: String
    var size: Size = .large
    var leadingAction: ActionItem? = nil
    var trailingActions: [ActionItem] = []

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let leadingAction {
                ProductTopBarAction(content: content(for: leadingAction.kind), action: leadingAction.action)
            }

            Text(title)
                .font(titleFont)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .tracking(AppFont.productHeading.tracking)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: AppSpacing.sm) {
                ForEach(trailingActions) { item in
                    ProductTopBarAction(content: content(for: item.kind), action: item.action)
                }
            }
        }
        .frame(height: 64)
    }

    private var titleFont: Font {
        switch size {
        case .md: return AppFont.productHeading.font
        case .large: return AppFont.productHeading.font
        }
    }

    private func content(for kind: ActionItem.Kind) -> ProductTopBarAction.Content {
        switch kind {
        case .text(let label):
            return .text(label)
        case .icon(let icon):
            return .icon(icon)
        }
    }
}

/// Set-step tracker inside `WorkoutCommandCard`. Renders the current set as a
/// filled capsule ("Set 2"), completed/failed sets as compact `kgxrep` chips, and
/// upcoming sets as numbered circles. Used only in active workout flows.
struct SetProgressIndicator: View {
    struct Step: Identifiable {
        enum State {
            case upcoming
            case current
            case completed
            case failed
            case disabled
        }

        let id: Int
        let label: String
        let state: State
        var reps: Int? = nil
        var weightText: String? = nil

        var chipText: String? {
            guard let reps, let weightText, !weightText.isEmpty else { return nil }
            return "\(weightText)x\(reps)"
        }
    }

    let steps: [Step]

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(steps) { step in
                Group {
                    if step.state == .current {
                        Text("Set \(step.label)")
                            .font(AppFont.stepIndicator.font)
                            .foregroundStyle(AppColor.accentForeground)
                            .padding(.horizontal, AppSpacing.smd)
                            .frame(height: 24)
                            .background(Capsule().fill(AppColor.accent))
                    } else if (step.state == .completed || step.state == .failed),
                              let chipText = step.chipText {
                        HStack(spacing: AppSpacing.xxs) {
                            if step.state == .completed {
                                AppIcon.checkmark.image(size: 10, weight: .bold)
                            } else {
                                AppIcon.remove.image(size: 10, weight: .bold)
                            }
                            Text(chipText)
                                .font(.geistMono(.semibold, size: 12))
                                .lineLimit(1)
                        }
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, AppSpacing.sm)
                        .frame(height: 24)
                        .background(Capsule().fill(AppColor.controlBackground))
                    } else {
                        ZStack {
                            Circle()
                                .fill(backgroundColor(for: step.state))
                                .frame(width: 24, height: 24)

                            switch step.state {
                            case .completed:
                                AppIcon.checkmark.image(size: 10, weight: .bold)
                                    .foregroundStyle(AppColor.textPrimary)
                            case .failed:
                                AppIcon.remove.image(size: 10, weight: .bold)
                                    .foregroundStyle(AppColor.textPrimary)
                            default:
                                Text(step.label)
                                    .font(AppFont.stepIndicator.font)
                                    .foregroundStyle(foregroundColor(for: step.state))
                            }
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel(for: step))
            }
        }
    }

    private func backgroundColor(for state: Step.State) -> Color {
        switch state {
        case .current:
            return AppColor.accent
        case .disabled:
            return AppColor.background
        case .completed, .failed, .upcoming:
            return AppColor.controlBackground
        }
    }

    private func foregroundColor(for state: Step.State) -> Color {
        switch state {
        case .current:
            return AppColor.accentForeground
        case .disabled:
            return AppColor.textSecondary
        case .completed, .failed, .upcoming:
            return AppColor.textSecondary
        }
    }

    private func accessibilityLabel(for step: Step) -> String {
        let detail = step.chipText.map { ", \($0)" } ?? ""
        switch step.state {
        case .completed:
            return "Set \(step.label), completed\(detail)"
        case .failed:
            return "Set \(step.label), below target\(detail)"
        case .current:
            return "Set \(step.label), current"
        case .upcoming:
            return "Set \(step.label), upcoming"
        case .disabled:
            return "Set \(step.label), unavailable"
        }
    }
}

/// Rest countdown control — `-15` / central timer pill / `+15`. Sits inside
/// `SessionStateBar` (detached bottom sheet) or `WorkoutCommandCard` (inline).
/// `.ready` state drops the capsule so the transition to "done resting" reads
/// as a deliberate visual beat, not just a color change.
struct RestTimerControl: View {
    enum State: Equatable {
        case idle
        case running
        case paused
        case ready
        case disabled
    }

    let timeText: String
    var state: State = .running
    var onDecrease: (() -> Void)? = nil
    var onToggle: (() -> Void)? = nil
    var onIncrease: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.lg) {
                adjustButton(icon: .remove, action: onDecrease)

                Button(action: { onToggle?() }) {
                    Group {
                        if showsTimerCapsule {
                            timerCenterTapLabel
                                .clipShape(Capsule())
                                .contentShape(Capsule())
                        } else {
                            timerCenterTapLabel
                                .contentShape(Rectangle())
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(onToggle == nil || state == .disabled)
                .accessibilityLabel(timerAccessibilityLabel)

                adjustButton(icon: .add, action: onIncrease)
            }
        }
        .opacity(state == .disabled ? 0.5 : 1)
    }

    private var timerCenterTapLabel: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(timeText)
                .font(AppFont.numericDisplay.font)
                .tracking(AppFont.numericDisplay.tracking)
                .foregroundStyle(timerCenterForeground)
                .monospacedDigit()
                // Per-second countdown roll. iOS picks the changed digits and
                // fades them downward so the timer reads as deliberately
                // ticking instead of flickering. State-only motion → not
                // gated by Reduce Motion (cross-fade survives the system pref).
                .contentTransition(.numericText(countsDown: true))
                .animation(.appReveal, value: timeText)

            if let indicatorIcon {
                indicatorIcon.image(size: 18, weight: .semibold)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(minHeight: 60)
        .padding(.horizontal, AppSpacing.smd)
        .background {
            if showsTimerCapsule {
                Capsule().fill(AppColor.controlBackground)
            }
        }
        .overlay {
            if showsTimerCapsule {
                Capsule()
                    .stroke(AppColor.border.opacity(0.55), lineWidth: 1)
            }
        }
    }

    /// Capsule fill + stroke for **idle / paused / disabled** so the affordance reads as
    /// tappable when not actively counting. Drops to plain text for **running** and **ready**:
    /// while running, the numeral is the hero of the screen (Beside-style isolation); when
    /// ready, the absence of chrome reads as a deliberate "done resting" beat.
    private var showsTimerCapsule: Bool {
        switch state {
        case .running, .ready:
            return false
        case .idle, .paused, .disabled:
            return true
        }
    }

    private var timerCenterForeground: Color {
        switch state {
        case .ready:
            return AppColor.textSecondary
        default:
            return AppColor.textPrimary
        }
    }

    private var timerAccessibilityLabel: String {
        switch state {
        case .idle:
            return timeText
        case .paused:
            return "\(timeText), paused"
        case .running:
            return "\(timeText), running"
        case .ready:
            return "\(timeText), ready"
        case .disabled:
            return "Timer unavailable"
        }
    }

    private var indicatorIcon: AppIcon? {
        switch state {
        case .idle, .paused:
            return .play
        case .running:
            return .pause
        case .ready, .disabled:
            return nil
        }
    }

    private func adjustButton(icon: AppIcon, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            icon.image(size: 26, weight: .semibold)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 60, height: 60)
                .background(AppColor.controlBackground)
                .overlay {
                    Circle()
                        .stroke(AppColor.border.opacity(0.4), lineWidth: 1)
                }
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(action == nil || state == .disabled)
    }
}

// MARK: - PreviewListRow + PreviewListContainer

/// Two-line row for preview lists inside cards (Today's exercise preview,
/// Programs day list). Uses `AppFont.sectionHeader` for title + `listSecondary`
/// for subtitle. `isEmptyHint = true` demotes the subtitle to a softer hint
/// color for cold-start rows like "No prior sets".
struct PreviewListRow: View {
    let title: String
    let subtitle: String
    /// When `true`, subtitle uses lighter system secondary label (empty-state hints).
    var isEmptyHint: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(titleColor)

            Text(subtitle)
                .font(subtitleFont)
                .foregroundStyle(subtitleColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpacing.sm)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }

    private var titleColor: Color { AppColor.textPrimary }

    private var subtitleFont: Font {
        isEmptyHint ? AppFont.caption.font : AppFont.body.font
    }

    private var subtitleColor: Color {
        AppColor.textSecondary
    }
}

/// Scrollable, capped-height container for `PreviewListRow`s — used on Today hero
/// and in program active-card previews. Top + bottom edges fade via the
/// canonical `appScrollEdgeSoft()` so truncation reads intentionally; the OS
/// only renders the fade where scrolling actually clips, so short content
/// stays flat without measuring height by hand.
struct PreviewListContainer<Content: View>: View {
    var maxHeight: CGFloat = 228
    /// Vertical gap between rows. Tight by default so the container padding can breathe around the group.
    var rowSpacing: CGFloat = AppSpacing.xs
    /// Inner padding between the container edge and its rows.
    var contentPadding: CGFloat = AppSpacing.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: rowSpacing) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(contentPadding)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: maxHeight)
        .appScrollEdgeSoft()
        // Canonical row-on-card recipe (Figma source of truth, 2026-04-27):
        // `cardRowFill` + `AppRadius.sm` for any element nested inside `AppCard`.
        .background(AppColor.cardRowFill)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
    }
}

// MARK: - Organisms

/// Canonical card surface — white fill, continuous corners, thin stroke,
/// dual lift shadows. The default chrome for any grouped surface. Use `.appCardStyle()`
/// instead when a wrapper type is awkward (e.g. applied to an existing VStack
/// without re-nesting). Never invent inline `.background(...).clipShape(...)` chrome.
struct AppCard<Content: View>: View {
    /// Outer inset for card chrome. System default is `AppSpacing.lg` (24pt) so every
    /// card has 24pt visual breathing room from card edge to content. Use the default
    /// when the body owns no horizontal padding of its own (text, buttons, custom
    /// layouts). For list content where the inner row already pads itself by
    /// `AppSpacing.md` (16pt) — `AppListRow`, or any row with explicit
    /// `.padding(.horizontal, .md)` — pass `AppSpacing.sm` (8pt) so 8 + 16 composes
    /// to the same 24pt offset. Use `0` only for full-bleed content (dividers
    /// running card-edge to card-edge, media). Anything else is the wrong inset.
    var contentInset: CGFloat = AppSpacing.lg
    /// Optional vertical override. When the card's content is a list whose rows
    /// already own vertical padding (e.g. `AppDividedList` of `AppListRow` /
    /// `PreviewListRow`), pass a smaller value here so the card chrome doesn't
    /// compound with the row padding and create asymmetric edge-vs-between
    /// spacing. `nil` (default) uses `contentInset` on all four sides — current
    /// behavior for non-list cards.
    var verticalInset: CGFloat? = nil
    /// Corner radius for clip + stroke; default matches `AppRadius.lg` cards app-wide.
    var cornerRadius: CGFloat = AppRadius.lg
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.horizontal, contentInset)
        .padding(.vertical, verticalInset ?? contentInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .modifier(AppCardElevation(cornerRadius: cornerRadius))
    }
}

/// Session header row: eyebrow (date), title (template name), optional caption,
/// trailing status. No card chrome — use directly as a row inside `AppCardList`
/// (history list of sessions) or compose into `AppSessionHighlightCard` when a
/// single session needs its own elevated surface (missed-day card, earlier-week
/// catch-up). Single source of truth for the session header layout.
struct AppSessionHighlightRow<Trailing: View>: View {
    let eyebrow: String
    let title: String
    let caption: String?
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(eyebrow)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textSecondary)

                Text(title)
                    .font(AppFont.title.font)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                if let caption, !caption.isEmpty {
                    Text(caption)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer(minLength: 0)

            trailing()
        }
    }
}

/// Session highlight as a single elevated card. Wraps `AppSessionHighlightRow`
/// in `AppCard` chrome and optionally appends extra detail beneath the header
/// (separated by an `AppDivider`) — used by the calendar summary sheet where
/// the session header is followed by a context note + per-exercise breakdown.
/// For lists of multiple sessions on a single surface, use
/// `AppSessionHighlightRow` inside `AppCardList` instead — never stack
/// per-row `AppSessionHighlightCard`s in a list (CLAUDE.md §5: no per-row
/// shadowed cards in lists).
struct AppSessionHighlightCard<Trailing: View, BelowContent: View>: View {
    let eyebrow: String
    let title: String
    let caption: String?
    @ViewBuilder let trailing: () -> Trailing
    @ViewBuilder let belowContent: () -> BelowContent

    var body: some View {
        AppCard(contentInset: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                AppSessionHighlightRow(
                    eyebrow: eyebrow,
                    title: title,
                    caption: caption,
                    trailing: trailing
                )

                if BelowContent.self != EmptyView.self {
                    AppDivider()
                    belowContent()
                }
            }
        }
    }
}

extension AppSessionHighlightCard where BelowContent == EmptyView {
    init(
        eyebrow: String,
        title: String,
        caption: String?,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.caption = caption
        self.trailing = trailing
        self.belowContent = { EmptyView() }
    }
}

/// Transient pill-shaped notification anchored to the bottom safe area.
/// Bind `message` to a `String?` `@State`; setting non-nil shows the toast,
/// which auto-dismisses after `duration` seconds.
struct AppToast: ViewModifier {
    @Binding var message: String?
    var duration: TimeInterval = 3.0

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let text = message {
                    Text(text)
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColor.cardBackground)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColor.border, lineWidth: 1))
                        .padding(.bottom, AppSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task(id: text) {
                            try? await Task.sleep(for: .seconds(duration))
                            withAnimation(.appState) {
                                message = nil
                            }
                        }
                }
            }
            .animation(.appState, value: message)
    }
}

extension View {
    /// Show a transient bottom toast bound to a `String?` state.
    func appToast(message: Binding<String?>, duration: TimeInterval = 3.0) -> some View {
        modifier(AppToast(message: message, duration: duration))
    }
}

/// Empty-state card. Two shapes share one molecule:
/// 1. **CTA-bearing** (`eyebrow` + `title` + `message` + `buttonLabel` + `action`) — for
///    features the user *can* fix from this screen (no program → "Create program").
/// 2. **Quiet** (`title` + `message`) — for screens where the missing data is created
///    elsewhere (History → "No sessions yet").
///
/// Compose inside `AppScreen`; don't rebuild a title+message card in-place when this
/// covers the shape. Per CLAUDE.md §5 (extend > create), variants live behind one
/// struct so list screens converge instead of forking.
struct EmptyStateCard<Content: View>: View {
    let eyebrow: String?
    let title: String
    let message: String
    let note: String?
    let buttonLabel: String?
    let action: (() -> Void)?
    let content: () -> Content

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                if let eyebrow {
                    Text(eyebrow)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                }

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppFont.productHeading.font)
                        .tracking(AppFont.productHeading.tracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(message)
                        .font(AppFont.productAction.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)

                    if let note {
                        Text(note)
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if Content.self != EmptyView.self {
                    content()
                }

                if let buttonLabel, let action {
                    AppPrimaryButton(buttonLabel, action: action)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension EmptyStateCard where Content == EmptyView {
    /// CTA-bearing empty state (primary use — feature can be initiated here).
    init(eyebrow: String, title: String, message: String, buttonLabel: String, action: @escaping () -> Void) {
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.note = nil
        self.buttonLabel = buttonLabel
        self.action = action
        self.content = { EmptyView() }
    }

    /// Quiet empty state — title + message only, for screens where missing data is
    /// created elsewhere. Replaces hand-rolled `AppCard { VStack { Text + Text } }`.
    init(title: String, message: String) {
        self.eyebrow = nil
        self.title = title
        self.message = message
        self.note = nil
        self.buttonLabel = nil
        self.action = nil
        self.content = { EmptyView() }
    }

    /// Hero variant without inline content or CTA — used by Today's rest-day card
    /// (eyebrow + title + subtitle, nothing else).
    init(eyebrow: String, title: String, message: String) {
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.note = nil
        self.buttonLabel = nil
        self.action = nil
        self.content = { EmptyView() }
    }
}

extension EmptyStateCard {
    /// Hero variant with an inline content slot above the CTA — used by Today's
    /// "Up next" card to embed a tappable preview list. Optional `note:` renders
    /// a caption beneath the subtitle (e.g. "Different routine for today").
    init(
        eyebrow: String,
        title: String,
        message: String,
        note: String? = nil,
        buttonLabel: String,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.note = note
        self.buttonLabel = buttonLabel
        self.action = action
        self.content = content
    }
}

/// Lightweight transient empty state — caption-sized message centered in a
/// card-chromed surface. Use when a filter or search has returned no results
/// (Program library "No programs match these filters", Exercises list search
/// empty, History filter empty). Distinct from `EmptyStateCard`, which is the
/// heavy cold-start treatment for "no data yet" with eyebrow + title + message
/// + CTA. `AppEmptyHint` carries no eyebrow, no title, no action — just a
/// quiet hint that the current filter/search produced nothing.
struct AppEmptyHint: View {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var body: some View {
        Text(message)
            .font(AppFont.caption.font)
            .foregroundStyle(AppColor.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .appCardStyle()
    }
}

/// Canonical row-list primitive. Renders rows separated by a 1pt `AppDivider`
/// hairline. Use inside a shared `AppCard` (or `SettingsSection`) when rows
/// share a subject; for a list that owns its own card chrome, use the
/// `AppCardList` molecule instead. Dividers default to full container width
/// (leading/trailing 0); pass `dividerLeading:` / `dividerTrailing:` only when
/// a non-full-width inset is genuinely required.
struct AppDividedList<Data, ID, RowContent>: View
    where Data: RandomAccessCollection, ID: Hashable, RowContent: View
{
    let data: Data
    let id: KeyPath<Data.Element, ID>
    var dividerLeading: CGFloat = 0
    var dividerTrailing: CGFloat = 0
    @ViewBuilder let content: (Data.Element) -> RowContent

    var body: some View {
        let items = Array(data)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                if index > 0 {
                    AppDivider()
                        .padding(.leading, dividerLeading)
                        .padding(.trailing, dividerTrailing)
                }
                content(items[index])
            }
        }
    }
}

extension AppDividedList where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        dividerLeading: CGFloat = 0,
        dividerTrailing: CGFloat = 0,
        @ViewBuilder content: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = \.id
        self.dividerLeading = dividerLeading
        self.dividerTrailing = dividerTrailing
        self.content = content
    }
}

/// Canonical "list inside its own card" molecule. The card runs full-bleed
/// horizontally (`contentInset: 0`) so the 1pt `AppDivider` hairlines extend
/// card-edge to card-edge — the documented full-width-of-container rule. Rows
/// pad themselves by `AppSpacing.lg` (24pt) to land at the canonical 24pt
/// text-from-edge offset, and the molecule enforces a 52pt minimum row height
/// (matching `PreviewListRow` / `AppCardListAddRow`) so single-line text rows
/// never collapse to a 44pt tap-target floor and read tight against the
/// dividers. Use this anywhere you'd otherwise compose `AppCard` +
/// `AppDividedList` by hand — that combination is banned in feature code
/// (see CLAUDE.md §5 + `.claude/hooks/ui-banned-list.sh`).
///
/// Optional `trailing:` slot renders one extra divided row after the data
/// rows — typically an `AppCardListAddRow("Add X")` affordance, matching the
/// in-card add convention used elsewhere. The trailing row is preceded by an
/// `AppDivider` only when there is at least one data row, so the empty state
/// (just the add affordance) reads as one clean row.
///
/// For list content nested inside a `SettingsSection` or another `AppCard`
/// (which already provides card chrome), use `AppDividedList` directly — the
/// hairline divider is shared.
struct AppCardList<Data, ID, RowContent, Trailing>: View
    where Data: RandomAccessCollection, ID: Hashable, RowContent: View, Trailing: View
{
    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let row: (Data.Element) -> RowContent
    private let trailing: () -> Trailing

    var body: some View {
        // verticalInset matches the row's internal `.padding(.vertical, .sm)` so
        // edge breathing (8 + 8 = 16pt) reads symmetrically against between-rows
        // breathing (8 + 1pt divider + 8 = 17pt). Anything smaller pinches the
        // first/last row against the card edge.
        //
        // Row min-height of 52pt matches `PreviewListRow` and `AppCardListAddRow`
        // so single-line rows (`OnboardingSplitBuilderView`) get the canonical
        // breathing room for free instead of collapsing to a 44pt tap-target floor.
        AppCard(contentInset: 0, verticalInset: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: 0) {
                AppDividedList(data: data, id: id) { item in
                    row(item)
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                }
                if Trailing.self != EmptyView.self {
                    if !data.isEmpty {
                        AppDivider()
                    }
                    trailing()
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                }
            }
        }
    }
}

extension AppCardList where Trailing == EmptyView {
    init(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder row: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = id
        self.row = row
        self.trailing = { EmptyView() }
    }
}

extension AppCardList where Data.Element: Identifiable, ID == Data.Element.ID, Trailing == EmptyView {
    init(_ data: Data, @ViewBuilder row: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.id = \.id
        self.row = row
        self.trailing = { EmptyView() }
    }
}

extension AppCardList where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        @ViewBuilder row: @escaping (Data.Element) -> RowContent,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.data = data
        self.id = \.id
        self.row = row
        self.trailing = trailing
    }
}

/// Trailing affordance for an `AppCardList` — a "+ Add X" row that sits as
/// the final divided row of the list. Renders an accent-colored title beside
/// `addCircle`, matching the in-card add convention used in
/// `TemplateDetailView`. 52pt min-height aligns with `PreviewListRow` so the
/// rhythm reads uniform whether the list is empty or full. Place inside
/// `AppCardList(_:row:trailing:)`'s `trailing:` closure — never as a free
/// floating button below the card.
struct AppCardListAddRow: View {
    private let title: String
    private let icon: AppIcon
    private let action: () -> Void

    init(_ title: String, icon: AppIcon = .addCircle, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                icon.image()
                Text(title)
                    .font(AppFont.body.font)
                Spacer(minLength: 0)
            }
            .foregroundStyle(AppColor.accent)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Active-workout hero — set progress strip + exercise name + metric hero +
/// primary "Log set" CTA, with an optional rest-timer strip at the bottom.
/// This is the central surface of `ActiveWorkoutView`; never build a page-local
/// command panel to replace it. Timer strip is hidden when `timerValue == nil`.
struct WorkoutCommandCard: View {
    enum State: Equatable {
        case active
        case completed
        case disabled
    }

    let progressSteps: [SetProgressIndicator.Step]
    let exerciseName: String
    let metricValue: String
    var metricSupportingText: String? = nil
    /// When true, the metric line uses body-sized copy instead of the large numeric display (placeholders).
    var metricIsHint: Bool = false
    var state: State = .active
    var primaryLabel: String = AppCopy.Workout.completeSet
    var onPrimaryAction: (() -> Void)? = nil
    var onSecondaryAction: (() -> Void)? = nil
    /// Bumped by the parent each time a set is logged. Drives the success
    /// haptic on this card so the feedback lives at the atom layer instead of
    /// being threaded through `UIImpactFeedbackGenerator` at the call site.
    /// Pass `nil` for non-active surfaces (previews) — feedback is a no-op then.
    var setLoggedSignal: Int? = nil
    var timerValue: String? = nil
    var timerState: RestTimerControl.State = .idle
    var onTimerDecrease: (() -> Void)? = nil
    var onTimerToggle: (() -> Void)? = nil
    var onTimerIncrease: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: AppSpacing.lg) {
                HStack {
                    Spacer(minLength: 0)
                    SetProgressIndicator(steps: progressSteps)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)

                Text(exerciseName)
                    .font(AppFont.productHeading.font)
                    .tracking(AppFont.productHeading.tracking)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                metricHero

                if let metricSupportingText, !metricSupportingText.isEmpty {
                    Text(metricSupportingText)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if state != .completed {
                    AppPrimaryButton(
                        primaryLabel,
                        isEnabled: state == .active && onPrimaryAction != nil,
                        action: { onPrimaryAction?() }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)

            if let timerValue {
                Rectangle()
                    .fill(AppColor.border.opacity(0.32))
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)

                RestTimerControl(
                    timeText: timerValue,
                    state: timerState,
                    onDecrease: onTimerDecrease,
                    onToggle: onTimerToggle,
                    onIncrease: onTimerIncrease
                )
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity)
        .appWorkoutPanelChrome()
        .sensoryFeedback(.success, trigger: setLoggedSignal)
    }

    @ViewBuilder
    private var metricHero: some View {
        if onSecondaryAction != nil {
            if metricIsHint {
                AppSecondaryButton(
                    AppCopy.Workout.logMetricHint,
                    isEnabled: state == .active,
                    fillsAvailableWidth: false,
                    action: { onSecondaryAction?() }
                )
                .accessibilityLabel("Log weight and reps")
            } else {
                Button(action: { onSecondaryAction?() }) {
                    VStack(spacing: AppSpacing.xs) {
                        metricValueText

                        Text("Adjust")
                            .font(AppFont.smallLabel.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Adjust weight and reps")
            }
        } else {
            metricValueText
        }
    }

    @ViewBuilder
    private var metricValueText: some View {
        Text(metricValue)
            .font(AppFont.numericDisplay.font)
            .tracking(AppFont.numericDisplay.tracking)
            .foregroundStyle(AppColor.textPrimary)
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.55)
            .lineLimit(3)
            // Numeric cross-fade between sets — when prefill updates after a
            // logged set, the weight × reps swap reads as a soft handoff
            // instead of a flicker. SwiftUI selects per-glyph fade for the
            // changed digits and leaves the rest static.
            .contentTransition(.numericText())
            .accessibilityLabel(Self.voiceOverLabel(forMetric: metricValue))
    }

    /// Translate the compact metric token (`3x8x80kg`, `BWx12`) into a
    /// VoiceOver-friendly phrase. `x` becomes " by ", `BW` expands to
    /// "bodyweight". Keeps the visible glyphs untouched — the numeric column
    /// stays tight on screen while screen-reader users get a sentence.
    static func voiceOverLabel(forMetric metric: String) -> String {
        metric
            .replacingOccurrences(of: "BW", with: "bodyweight")
            .replacingOccurrences(of: "x", with: " by ")
    }
}

/// Bottom-anchored state bar for active sessions. Renders rest timer (running /
/// paused / complete) or "Next exercise" subtitle + advance action. Compose via
/// `.safeAreaInset(edge: .bottom)` on `ActiveWorkoutView` so it floats above the
/// tab bar, never scrolls with content.
struct SessionStateBar: View {
    enum State {
        case restRunning(countdown: String, helperText: String?)
        case restPaused(countdown: String, helperText: String?)
        case restComplete(helperText: String?)
        case nextExercise(subtitle: String)
    }

    let state: State
    var onDecreaseRest: (() -> Void)? = nil
    var onToggleRest: (() -> Void)? = nil
    var onIncreaseRest: (() -> Void)? = nil
    var onAdvance: (() -> Void)? = nil

    var body: some View {
        switch state {
        case .nextExercise:
            nextExerciseButton
        default:
            VStack(spacing: 0) {
                content
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.lg)
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.background)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .restRunning(let countdown, let helperText):
            restContent(
                title: "Rest",
                helperText: helperText,
                controlState: .running,
                countdown: countdown
            )

        case .restPaused(let countdown, let helperText):
            restContent(
                title: "Rest",
                helperText: helperText,
                controlState: .paused,
                countdown: countdown
            )

        case .restComplete(let helperText):
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Ready")
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                if let helperText, !helperText.isEmpty {
                    Text(helperText)
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .nextExercise:
            EmptyView()
        }
    }

    private var nextExerciseButton: some View {
        Group {
            if case .nextExercise(let subtitle) = state {
                AppSecondaryButton(
                    AppCopy.Workout.nextExercise,
                    isEnabled: onAdvance != nil,
                    icon: nil,
                    detail: subtitle,
                    detailAlignment: .center,
                    detailLayout: .inline,
                    action: { onAdvance?() }
                )
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
                .frame(maxWidth: .infinity)
                .background(AppColor.background)
            }
        }
    }

    private func restContent(
        title: String,
        helperText: String?,
        controlState: RestTimerControl.State,
        countdown: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.caption.font)
                .foregroundStyle(AppColor.textSecondary)

            RestTimerControl(
                timeText: countdown,
                state: controlState,
                onDecrease: onDecreaseRest,
                onToggle: onToggleRest,
                onIncrease: onIncreaseRest
            )

            if let helperText, !helperText.isEmpty {
                Text(helperText)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Section header line — title text plus an optional trailing accessory
/// (e.g. "Reorder", "Edit", "See all"). Use as the heading of any titled
/// group whose body is a standalone surface (`AppCardList`, an
/// `appInputFieldStyle()` field, custom card content). For groups whose
/// body needs its own card chrome around free-form content, use
/// `SettingsSection` — which composes this header internally.
struct AppSectionHeader<Trailing: View>: View {
    private let title: String
    private let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppFont.sectionHeader.color)
            Spacer(minLength: 0)
            trailing()
        }
    }
}

extension AppSectionHeader {
    init(_ title: String, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.trailing = trailing
    }
}

extension AppSectionHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.init(title) { EmptyView() }
    }
}

/// Titled group: section-header text above an `AppCard` body. Default
/// `contentInset: AppSpacing.lg` (24pt) matches `AppCard`'s default chrome and is
/// right for plain content (single buttons, free-form copy, custom layouts) where
/// the body owns no horizontal padding of its own. For list content where the
/// inner row already pads itself by `AppSpacing.md` (16pt) — `AppListRow`,
/// `AppDividedList`, or any row with explicit `.padding(.horizontal, .md)` — pass
/// `contentInset: AppSpacing.sm` (8pt) so the outer 8 + inner 16 composes to the
/// canonical 24pt visual offset from card edge to row content. Passing
/// `contentInset: 0` is reserved for surfaces where rows must run card-edge to
/// card-edge (e.g. dividers spanning the full card width, full-bleed media).
struct SettingsSection<Content: View>: View {
    let title: String
    var contentInset: CGFloat = AppSpacing.lg
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        contentInset: CGFloat = AppSpacing.lg,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.contentInset = contentInset
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            AppSectionHeader(title)

            AppCard(contentInset: contentInset, verticalInset: resolvedVerticalInset) {
                VStack(alignment: .leading, spacing: contentInset == 0 ? 0 : AppSpacing.sm) {
                    content()
                }
            }
        }
    }

    /// In documented "list mode" (`contentInset == .sm`), the inner row already
    /// pads itself vertically. Compounding the card's 8pt vertical inset on top
    /// produces asymmetric edge-vs-between spacing (12pt edges, 9pt between for
    /// `.display` rows). Drop the card's vertical to `xs` (4pt) so 4 + 4 = 8pt
    /// edges align with 4 + divider + 4 = 9pt between rows. For non-list modes,
    /// keep symmetric padding (`nil` → uses `contentInset`).
    private var resolvedVerticalInset: CGFloat? {
        contentInset == AppSpacing.sm ? AppSpacing.xs : nil
    }
}

// MARK: - Template

/// Configures the sticky primary CTA baked into `AppScreen(primaryButton:)`.
/// Pass via `AppScreen(primaryButton: .init(label:action:))` — the screen renders
/// it inside a `.safeAreaInset(edge: .bottom)` so it floats above scroll content.
struct PrimaryButtonConfig {
    let label: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void
}

/// Quiet ghost CTA (e.g. onboarding "Back") rendered directly under the primary.
/// Renders as `AppGhostButton` — text-only, no fill — so it doesn't compete with
/// the primary. When set together with `primaryButton`, the pair reads as one unit:
/// they share one `.safeAreaInset(edge: .bottom)` with `AppSpacing.xs` (4pt)
/// between them. Use `AppScreen(secondaryButton:)` — never stack two separate
/// `.safeAreaInset`s.
struct SecondaryButtonConfig {
    let label: String
    var isEnabled: Bool = true
    let action: () -> Void
}

/// Page-level template: horizontal padding, optional `customHeader` (typically
/// `ProductTopBar` for root tabs) or system `NavigationStack` chrome, scrollable
/// body, optional sticky primary CTA. **Every full screen in the app composes
/// through `AppScreen`** — don't rebuild a ScrollView/VStack/nav-bar shell in a
/// feature view. Set `usesOuterScroll: false` for fixed dashboards where inner
/// controls own scrolling.
struct AppScreen<Content: View>: View {
    let primaryButton: PrimaryButtonConfig?
    let secondaryButton: SecondaryButtonConfig?
    let customHeader: AnyView?
    var hidesNavigationBar: Bool = false
    var showsNativeNavigationBar: Bool = false
    /// When `false`, the screen does not wrap content in `ScrollView` — use for fixed dashboards where an inner control (e.g. `PreviewListContainer`) owns vertical scrolling.
    var usesOuterScroll: Bool = true
    /// When `true`, adds a trailing **Done** on the keyboard accessory bar to dismiss first responder. Turn **off** for flows that use the standard keyboard (Return / Next / Done) so the accessory does not appear without a visible keyboard.
    var showsKeyboardDismissToolbar: Bool = true
    @ViewBuilder let content: () -> Content

    init(
        primaryButton: PrimaryButtonConfig? = nil,
        secondaryButton: SecondaryButtonConfig? = nil,
        customHeader: AnyView? = nil,
        hidesNavigationBar: Bool = false,
        showsNativeNavigationBar: Bool = false,
        usesOuterScroll: Bool = true,
        showsKeyboardDismissToolbar: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.customHeader = customHeader
        self.hidesNavigationBar = hidesNavigationBar
        self.showsNativeNavigationBar = showsNativeNavigationBar
        self.usesOuterScroll = usesOuterScroll
        self.showsKeyboardDismissToolbar = showsKeyboardDismissToolbar
        self.content = content
    }

    private var hasBottomBar: Bool { primaryButton != nil || secondaryButton != nil }

    /// Max content width — keeps the mobile layout on iPad / Mac.
    private var maxContentWidth: CGFloat { 430 }

    private var paddedMainContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            content()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, showsNativeNavigationBar ? AppSpacing.md : (customHeader == nil ? AppSpacing.md : AppSpacing.sm))
        .padding(.bottom, hasBottomBar ? 100 : AppSpacing.md)
        .frame(maxWidth: maxContentWidth)
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        Group {
            if usesOuterScroll {
                ScrollView {
                    paddedMainContent
                }
                .scrollDismissesKeyboard(.interactively)
                .appScrollEdgeSoft(
                    top: customHeader != nil || !hidesNavigationBar || showsNativeNavigationBar,
                    bottom: hasBottomBar
                )
            } else {
                paddedMainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if !showsNativeNavigationBar, let customHeader {
                customHeader
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.md)
                    .background(AppColor.background)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if hasBottomBar {
                VStack(spacing: AppSpacing.xs) {
                    if let primaryButton {
                        AppPrimaryButton(
                            primaryButton.label,
                            isEnabled: primaryButton.isEnabled,
                            isLoading: primaryButton.isLoading,
                            action: primaryButton.action
                        )
                    }
                    if let secondaryButton {
                        AppGhostButton(
                            secondaryButton.label,
                            isEnabled: secondaryButton.isEnabled,
                            action: secondaryButton.action
                        )
                    }
                }
                .frame(maxWidth: maxContentWidth - AppSpacing.md * 2)
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(AppColor.background)
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .toolbar(showsNativeNavigationBar ? .automatic : .hidden, for: .navigationBar)
        .toolbar {
            if showsKeyboardDismissToolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.accent)
                }
            }
        }
    }
}

// MARK: - Shared modifiers

extension View {
    /// `elevated` adds the canonical card shadow so sheet inputs read as lifted controls
    /// (matches Apple native form sheets). Default stays flat for in-flow row inputs.
    func appInputFieldStyle(
        height: CGFloat = 48,
        horizontalPadding: CGFloat = AppSpacing.md,
        lineWidth: CGFloat = 0.5,
        elevated: Bool = false
    ) -> some View {
        self
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: max(44, height))
            .frame(height: height)
            .background(AppColor.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColor.border, lineWidth: lineWidth)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .modifier(AppInputElevation(enabled: elevated))
    }

    /// Multi-line variant: vertical-axis TextFields expand with content, so the container
    /// uses `minHeight` + vertical padding instead of a fixed `height`.
    func appInputFieldStyleMultiline(
        minHeight: CGFloat,
        horizontalPadding: CGFloat = AppSpacing.md,
        verticalPadding: CGFloat = AppSpacing.sm,
        lineWidth: CGFloat = 0.5,
        elevated: Bool = false
    ) -> some View {
        self
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: minHeight, alignment: .topLeading)
            .background(AppColor.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColor.border, lineWidth: lineWidth)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .modifier(AppInputElevation(enabled: elevated))
    }

    /// Canonical card chrome applied as a modifier — matches `AppCard`'s defaults
    /// so both entry points are a single source of truth. Pass `AppSpacing.sm`
    /// when the wrapped content already owns 16pt horizontal padding (e.g.
    /// `AppListRow`) so 8 + 16 composes to the canonical 24pt visual offset.
    func appCardStyle(contentInset: CGFloat = AppSpacing.lg) -> some View {
        self
            .padding(contentInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .modifier(AppCardElevation())
    }

    /// Apply the canonical card shadow/stroke to a view that already provides its own
    /// background and clip shape (e.g. ad-hoc cards that can't use `AppCard` or `appCardStyle`).
    func appCardElevation() -> some View {
        modifier(AppCardElevation())
    }

    /// Card fill + canonical shadows — active workout command/timer panel (no border stroke).
    func appWorkoutPanelChrome() -> some View {
        modifier(AppWorkoutPanelChrome())
    }

    func appBottomSheetChrome() -> some View {
        modifier(AppBottomSheetChromeModifier())
    }

    func navigationBarTitleTruncated(_ title: String, maxGlyphCount: Int = 34) -> some View {
        navigationTitle(title.truncatedForNavigationTitle(maxGlyphCount: maxGlyphCount))
    }

    func appNavigationBarChrome() -> some View {
        self
            // Defer bar chrome to the global `UINavigationBar.appearance()` proxy configured in
            // `ContentView.configureNavigationBarAppearance()` — standard appearance has
            // `shadowColor = .clear` (no hairline) and scroll-edge appearance is transparent.
            // SwiftUI's `.toolbarBackground(Material.bar, .visible)` would generate its own
            // appearance with a default separator, overriding the proxy and producing the
            // visible hairline beneath the bar. The soft scroll-edge fade is the only piece
            // that still belongs here.
            .appScrollEdgeSoft()
            // Keep nav title + toolbar buttons (e.g. "Add Exercise" / "Done") visible when
            // a `.searchable` field becomes focused. Default behavior collapses them to make
            // room for search, which made auto-focused exercise pickers look like the title
            // and Done were fading out a second after the sheet opened. No-op on screens
            // without `.searchable`.
            .searchPresentationToolbarBehavior(.avoidHidingContent)
    }

    /// Canonical style for text-label toolbar buttons (e.g. "History", "Browse").
    /// Matches iOS-native bold top-bar actions so every screen reads the same weight.
    func appToolbarTextStyle() -> some View {
        self.font(AppFont.body.font.weight(.semibold))
    }

    /// iOS-native soft gradient fade at the ScrollView edges. Prevents the
    /// sharp-cut appearance of scrolled content meeting an opaque bar (nav bar,
    /// CTA, tab bar) on vertical scrolls, and the same sharp-cut at the
    /// leading/trailing inset on horizontal chip/filter strips. The OS only
    /// renders the fade where scrolling actually clips content, so calling this
    /// on a horizontal ScrollView fades leading/trailing automatically without
    /// extra parameters.
    ///
    /// This is the single canonical modifier for scroll-edge fade. Never add a
    /// parallel LinearGradient/mask-based fade; extend this instead.
    @ViewBuilder
    func appScrollEdgeSoft(top: Bool = true, bottom: Bool = true) -> some View {
        if #available(iOS 18.0, *) {
            switch (top, bottom) {
            case (true, true):   self.scrollEdgeEffectStyle(.soft, for: .all)
            case (true, false):  self.scrollEdgeEffectStyle(.soft, for: .top)
            case (false, true):  self.scrollEdgeEffectStyle(.soft, for: .bottom)
            case (false, false): self
            }
        } else {
            self
        }
    }

    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

// MARK: - Icon circle (shared styling for chevron buttons + status badges)

/// Canonical 36×36 circular surface for an icon. Used by both interactive
/// nav chevrons and read-only status badges so the icon weight/size stays
/// consistent across the product.
struct AppIconCircle<Icon: View>: View {
    enum Surface {
        case control                   // grey neutral
        case accentSoft                // `AppColor.accentSoft` (adaptive warm neutral / dim white)
        case background                // `AppColor.background` (on-card badge)
        case cardBackground            // `AppColor.cardBackground` (on-control-bg badge)
        case tinted(Color, opacity: Double)

        var backgroundColor: Color {
            switch self {
            case .control: return AppColor.controlBackground
            case .accentSoft: return AppColor.accentSoft
            case .background: return AppColor.background
            case .cardBackground: return AppColor.cardBackground
            case .tinted(let color, let opacity): return color.opacity(opacity)
            }
        }
    }

    var diameter: CGFloat = 36
    var surface: Surface = .control
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        icon()
            .frame(width: diameter, height: diameter)
            .background(surface.backgroundColor)
            .clipShape(Circle())
    }
}

/// Standard icon size + weight so all `AppIconCircle` icons match.
enum AppIconCircleSize {
    static let icon: CGFloat = 16
    static let weight: Font.Weight = .semibold
}

// MARK: - Custom segmented control

/// SwiftUI segmented control with a soft (non-pill) radius, larger label text,
/// and a **single sliding** selected pill (spring-animated) on a track that
/// reads clearly against `AppColor.background`. The pill separates from the
/// track via fill contrast (white on grey), not shadow — matches the
/// flat-by-fill rule from visual-language.md §4.
struct AppSegmentedControl<Item: Hashable & Identifiable>: View {
    @Binding var selection: Item
    let items: [Item]
    let title: (Item) -> String

    private let height: CGFloat = 40
    private let trackRadius: CGFloat = 14
    private let pillRadius: CGFloat = 11
    /// Uniform inset between the track edge and the pill (applied on all four sides).
    /// Using a single value keeps the pill visually centered inside the track.
    private let trackPadding: CGFloat = 4

    private var pillFill: Color { AppColor.cardBackground }

    /// Track fill — `controlBackground` is a step darker than `AppColor.background`
    /// so the track reads as a separated surface via contrast alone.
    private var trackFill: Color { AppColor.controlBackground }

    var body: some View {
        let trackShape = RoundedRectangle(cornerRadius: trackRadius, style: .continuous)

        ZStack(alignment: .leading) {
            // 1. Track background.
            trackShape.fill(trackFill)

            // 2. Pill — flat fill, no shadow.
            GeometryReader { geo in
                let count = max(items.count, 1)
                let segmentWidth = geo.size.width / CGFloat(count)
                let pillHeight = geo.size.height
                let index = items.firstIndex(where: { $0.id == selection.id }) ?? 0
                let pillX = CGFloat(index) * segmentWidth

                RoundedRectangle(cornerRadius: pillRadius, style: .continuous)
                    .fill(pillFill)
                    .frame(width: segmentWidth, height: pillHeight)
                    .offset(x: pillX)
                    .animation(.appConfirm, value: selection.id)
            }
            .padding(trackPadding)
            .clipShape(trackShape)

            // 3. Labels — drawn above the pill, never clipped so text stays crisp.
            //    Segment buttons span the full track height (40pt) so each tap
            //    target meets the 40pt hit-area floor; visual centering is
            //    unchanged because the text glyph is centered in the frame.
            //    Horizontal trackPadding still applies so first/last labels
            //    don't kiss the track edge.
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item == selection
                    Button {
                        if !isSelected {
                            selection = item
                        }
                    } label: {
                        Text(title(item))
                            .font(.geist(.semibold, size: 16))
                            .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, trackPadding)
        }
        .frame(height: height)
    }
}

private struct AppBottomSheetChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: AppSpacing.md)
            }
            .presentationDragIndicator(.visible)
            // Passing `nil` lets iOS use the system sheet corner radius, which matches
            // the device's display corner radius on modern iPhones. A custom value would
            // leave the bottom corners mis-aligned with the screen on iPhone 17.
            .presentationCornerRadius(nil)
            .presentationBackground(AppColor.background)
            .presentationContentInteraction(.scrolls)
            // Soft iOS-native gradient fade at both edges — consistent with full-screen pages.
            .appScrollEdgeSoft()
    }
}

/// Canonical press-feedback button style — 0.96x scale + `.appPress` easing.
/// Apply to every tappable card or row so "press" reads consistently. Press is
/// a touch confirmation, not motion, so this is intentionally not gated by
/// Reduce Motion (per Apple HIG: tactile feedback is permitted).
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.appPress, value: configuration.isPressed)
    }
}

extension String {
    func truncatedForNavigationTitle(maxGlyphCount: Int = 34) -> String {
        guard count > maxGlyphCount else { return self }
        let end = index(startIndex, offsetBy: maxGlyphCount)
        return String(self[..<end]).trimmingCharacters(in: .whitespaces) + "…"
    }
}
