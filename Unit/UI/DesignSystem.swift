//
//  DesignSystem.swift
//  Unit
//
//  Shared UI atoms, molecules, organisms, and screen wrapper.
//

import SwiftUI
import UIKit

// MARK: - Atoms

// MARK: Pre-refinement values (revert by replacing the block below)
// background: 0xEBEBEB | barBackground: 0xEBEBEB | cardBackground: 0xF6F6F6
// sheetBackground: 0xF6F6F6 | controlBackground: 0xEBEBEB | mutedFill: 0xDCDCDC
// disabledSurface: 0xC7C7C7 | border: 0xDCDCDC
// AppRadius — sm: 8, md: 12, lg: 20, card: 20
// AppCard shadow — ring black 6%, lift r1 y1 black 6%, ambient r2 y0 black 4%

/// Role-based color tokens. Every color used in the app resolves to a case here —
/// no `Color.black/.gray`, no raw hex literals in page files. Adaptive (light/dark)
/// via `uicolorAdaptive`, but the design is light-first per visual-language.md.
enum AppColor {
    static let background = Color(uiColor: uicolorAdaptive(light: 0xF5F5F5, dark: 0x0E0F12))
    static let barBackground = Color(uiColor: uicolorAdaptive(light: 0xF5F5F5, dark: 0x13151A))
    static let cardBackground = Color(uiColor: uicolorAdaptive(light: 0xFFFFFF, dark: 0x1D2026))
    static let sheetBackground = Color(uiColor: uicolorAdaptive(light: 0xFFFFFF, dark: 0x21252D))
    static let controlBackground = Color(uiColor: uicolorAdaptive(light: 0xE8E8E8, dark: 0x2C313A))
    static let mutedFill = Color(uiColor: uicolorAdaptive(light: 0xE8E8E8, dark: 0x313640))
    static let disabledSurface = Color(uiColor: uicolorAdaptive(light: 0xE8E8E8, dark: 0x2C313A))

    static let textPrimary = Color(uiColor: uicolorAdaptive(light: 0x0A0A0A, dark: 0xF5F7FA))
    static let textSecondary = Color(uiColor: uicolorAdaptive(light: 0x595959, dark: 0xB3B8C2))
    /// Disabled primary/secondary buttons — softer than `textSecondary` so inactive reads clearly.
    static let textDisabled = Color(uiColor: uicolorAdaptive(light: 0x949494, dark: 0x7A808C))
    /// Matches `UIColor.secondaryLabel` — lighter than `textSecondary`; empty-state hints in dense lists.
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let border = Color(uiColor: uicolorAdaptive(light: 0xE5E5E5, dark: 0x373C47))

    /// Filled segment in multi-step progress (e.g. onboarding) — softer than `textPrimary` but reads clearly against `border` for inactive steps.
    static let progressSegmentFill = Color(uiColor: uicolorAdaptive(light: 0x3A3A3A, dark: 0xA8ADB8))

    static let accent = Color(uiColor: uicolorAdaptive(light: 0x0A0A0A, dark: 0xF3F4F6))
    static let accentForeground = Color(uiColor: uicolorAdaptive(light: 0xF6F6F6, dark: 0x111317))

    /// Toolbar/tab tint — matches `accent` (neutral) so nav and tab chrome stay on-brand, not system blue.
    static let systemTint = accent
    static let accentSoft = Color(uiColor: uicolorAccentSoft())
    static let success = Color(uiColor: uicolorAdaptive(light: 0x34C759, dark: 0x30D158))
    static let warning = Color(uiColor: uicolorAdaptive(light: 0xFF9500, dark: 0xFF9F0A))
    static let error = Color(uiColor: uicolorAdaptive(light: 0xFF3B30, dark: 0xFF453A))

    /// Soft tint fills for status surfaces (calendar day cells, status badges).
    /// Replaces scattered `AppColor.success.opacity(0.18)` and peers.
    static let successSoft = success.opacity(0.18)
    static let warningSoft = warning.opacity(0.22)
    static let errorSoft = error.opacity(0.18)

    /// Accessible text colors paired with the matching `*Soft` backgrounds.
    /// Vivid `success` / `warning` fail WCAG AA contrast when set as text on their own
    /// soft tint; these darker shades are the chip foreground.
    static let successOnSoft = Color(uiColor: uicolorAdaptive(light: 0x1D7A38, dark: 0x6FE08A))
    static let warningOnSoft = Color(uiColor: uicolorAdaptive(light: 0x8A4A00, dark: 0xFFC777))
    static let errorOnSoft = Color(uiColor: uicolorAdaptive(light: 0xB3261E, dark: 0xFF8A82))

    static let scrim = Color(uiColor: uicolorScrim())
    static let shadow = Color(uiColor: uicolorAdaptive(light: 0x000000, dark: 0x000000))

    /// Splash tagline emphasis — orange override. Splash-only; do not use elsewhere (orange is otherwise reserved for the home-screen icon per §5).
    static let splashAccent = Color(uiColor: uicolorAdaptive(light: 0xFF4400, dark: 0xFF5A1F))

    private nonisolated static func uicolorAdaptive(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                blue: CGFloat(hex & 0x0000FF) / 255,
                alpha: 1
            )
        }
    }

    private nonisolated static func uicolorAccentSoft() -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.14)
                : UIColor(
                    red: 235 / 255,
                    green: 235 / 255,
                    blue: 235 / 255,
                    alpha: 1
                )
        }
    }

    private nonisolated static func uicolorScrim() -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0, alpha: 0.58)
                : UIColor(white: 0, alpha: 0.34)
        }
    }

}

/// Typography tokens. Prefer a case here over inline `.font(.system(size:))` so
/// hierarchy stays consistent. Minimum weight across the app is **medium** (500) —
/// never `.regular`. Static members (`numericDisplay`, `productHeading`, etc.) cover
/// one-off display contexts that don't map to the body hierarchy.
enum AppFont {
    case largeTitle
    case title
    case sectionHeader
    case body
    case label
    case caption
    /// Second line under a list title (e.g. “12 exercises”) — use with `sectionHeader` on the line above.
    case listSecondary
    case muted

    var font: Font {
        switch self {
        case .largeTitle:
            return .system(size: 22, weight: .bold, design: .rounded)
        case .title:
            return .system(size: 20, weight: .semibold, design: .rounded)
        case .sectionHeader:
            return .system(size: 17, weight: .semibold, design: .rounded)
        case .body:
            return .system(size: 17, weight: .medium, design: .rounded)
        case .label:
            return .system(size: 17, weight: .semibold, design: .rounded)
        case .caption:
            return .system(size: 15, weight: .medium, design: .rounded)
        case .listSecondary:
            return .system(size: 16, weight: .medium, design: .rounded)
        case .muted:
            return .system(size: 13, weight: .medium, design: .rounded)
        }
    }

    var color: Color {
        switch self {
        case .muted:
            return AppColor.textSecondary
        default:
            return AppColor.textPrimary
        }
    }

    /// Tracking value for display-level text (tighter spacing for large sizes).
    var tracking: CGFloat {
        switch self {
        case .largeTitle:
            return -0.4
        default:
            return 0
        }
    }

    static let overline: Font = .system(size: 10, weight: .semibold, design: .rounded)
    static let smallLabel: Font = .system(size: 11, weight: .medium, design: .rounded)
    static let display: Font = .system(size: 36, weight: .bold, design: .rounded)
    /// Splash brand showcase — sized to read big next to the brand mark without dominating. Splash-only; do not use elsewhere.
    static let splashTitle: Font = .system(size: 56, weight: .bold, design: .rounded)
    /// Splash support copy — eyebrow ("Welcome to") + tagline. Matched size so they read as a pair. Splash-only.
    static let splashWelcome: Font = .system(size: 16, weight: .medium, design: .rounded)
    static let numericDisplay: Font = .system(size: 36, weight: .bold, design: .rounded).monospacedDigit()
    static let numericLarge: Font = .system(size: 28, weight: .bold, design: .rounded).monospacedDigit()
    static let compactLabel: Font = .system(size: 12, weight: .semibold, design: .rounded).monospacedDigit()
    static let stepIndicator: Font = .system(size: 14, weight: .semibold, design: .rounded).monospacedDigit()
    static let productHeading: Font = .system(size: 24, weight: .semibold, design: .rounded)
    static let productAction: Font = .system(size: 17, weight: .semibold, design: .rounded).monospacedDigit()
    /// Set-result / PR rows. Matches inline `.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit()`.
    static let performance: Font = .system(size: 15, weight: .semibold, design: .rounded).monospacedDigit()

    /// Tracking for static font properties (display-level gets tighter spacing).
    static let displayTracking: CGFloat = -0.6
    static let splashTitleTracking: CGFloat = -1.2
    static let productHeadingTracking: CGFloat = -0.3
    static let numericDisplayTracking: CGFloat = -0.6
    static let numericLargeTracking: CGFloat = -0.4
    static let uppercaseLabelTracking: CGFloat = 1.0
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
/// `sm` compact chips/cells, `md` buttons + inputs, `lg` cards, `sheet` sheet
/// presentation corners. No other radii should appear in page code.
enum AppRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 30
    static let sheet: CGFloat = 40

    /// Corner radius for a square tile so `RoundedRectangle(..., style: .continuous)` matches the iPhone Home Screen app icon mask (Apple icon grid: `10/57 × side length`).
    static func appIconHomeScreenCornerRadius(sideLength: CGFloat) -> CGFloat {
        sideLength * 10 / 57
    }
}

/// Shared sizing for day/week steppers and compact day badges (Paper e.g. node 2P1-0).
enum AppProgressChipMetrics {
    static let rowHeight: CGFloat = 20
    static var compactHorizontalPadding: CGFloat { AppSpacing.sm }
}

/// Canonical row/section separator. Renders as vertical whitespace — items are
/// separated by breathing room, not hairlines, per the light/quiet visual language.
/// Use `spacing: .sm` between list rows inside a shared card (tighter contexts
/// still default to `xs`). Pre-refinement: this was a 1px line in `AppColor.border`.
struct AppDivider: View {
    var spacing: CGFloat = AppSpacing.xs

    var body: some View {
        Color.clear
            .frame(height: spacing)
            .frame(maxWidth: .infinity)
    }
}

/// Unit brand mark — three ascending rounded bars mirroring the app-icon glyph.
/// Rendered in `AppColor.textPrimary` so it reads black in-app (the orange
/// backdrop is reserved for the home-screen icon only, per §banned-in-view-code).
struct AppBrandMark: View {
    var size: CGFloat = 56

    var body: some View {
        let barWidth = size * 0.2
        let gap = size * 0.08
        let radius = barWidth * 0.4

        HStack(alignment: .bottom, spacing: gap) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .frame(width: barWidth, height: size * 0.42)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .frame(width: barWidth, height: size * 0.68)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .frame(width: barWidth, height: size * 0.94)
        }
        .frame(width: size, height: size, alignment: .bottom)
        .foregroundStyle(AppColor.textPrimary)
    }
}

/// Shared card elevation — used by AppCard and .appCardStyle() for consistent depth.
private struct AppCardElevation: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : Color.black.opacity(0.03),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.06), radius: 6, x: 0, y: 3)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04), radius: 16, x: 0, y: 8)
    }
}

/// Subtle lift for sheet-hosted input fields so they read as controls (not flat blocks)
/// while staying softer than full `AppCardElevation`. Borders remain the primary affordance.
private struct AppInputElevation: ViewModifier {
    let enabled: Bool
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if enabled {
            content
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04), radius: 4, x: 0, y: 2)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.03), radius: 10, x: 0, y: 6)
        } else {
            content
        }
    }
}

/// Workout logging surface: card fill + same lift shadows as `AppCardElevation` (no stroke — shadow only).
private struct AppWorkoutPanelChrome: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.06), radius: 6, x: 0, y: 3)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.04), radius: 16, x: 0, y: 8)
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

/// Icon-based nav bar action descriptor. Used by `AppNavBar` + `AppScreen`.
struct NavAction {
    let icon: AppIcon
    let action: () -> Void
}

/// Text-label nav bar action descriptor. Used by `AppNavBar` + `AppScreen`.
struct NavTextAction {
    let label: String
    let action: () -> Void
}

/// 44pt-tall fixed navigation bar with centered title and optional leading/trailing
/// icon or text actions. Used for detail-flow screens driven by `AppScreen`'s
/// legacy nav path. Root/product screens should prefer `ProductTopBar` instead.
struct AppNavBar: View {
    let title: String?
    let leadingAction: NavAction?
    let trailingAction: NavAction?
    let trailingText: NavTextAction?

    var body: some View {
        ZStack {
            if let title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(title)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppFont.sectionHeader.color)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)
            }

            HStack {
                if let leadingAction {
                    iconButton(leadingAction)
                } else {
                    Spacer().frame(width: 44)
                }

                Spacer()

                trailingSlot
            }
        }
        .frame(height: 44)
        .padding(.horizontal, AppSpacing.sm)
    }

    /// Trailing slot: icon + text if both, else text, else icon, else a 44pt spacer
    /// so the title stays centered in the `ZStack`.
    @ViewBuilder
    private var trailingSlot: some View {
        switch (trailingAction, trailingText) {
        case (let icon?, let text?):
            HStack(spacing: AppSpacing.xs) {
                iconButton(icon)
                textButton(text)
            }
        case (nil, let text?):
            textButton(text)
        case (let icon?, nil):
            iconButton(icon)
        case (nil, nil):
            Spacer().frame(width: 44)
        }
    }

    private func iconButton(_ navAction: NavAction) -> some View {
        Button(action: navAction.action) {
            navAction.icon.image(size: 17, weight: .semibold)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func textButton(_ navText: NavTextAction) -> some View {
        Button(action: navText.action) {
            Text(navText.label)
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.textPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}

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

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            stepButton(icon: .remove, action: onDecrement)

            Text(value)
                .font(AppFont.label.font)
                .foregroundStyle(AppFont.label.color)
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(minWidth: minimumValueWidth)

            stepButton(icon: .add, action: onIncrement)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func stepButton(icon: AppIcon, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon.image(size: 14, weight: .semibold)
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                .padding(AppSpacing.sm)

            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.body.font)
                    .foregroundStyle(AppColor.textSecondary)
                    // TextEditor's internal NSTextContainer inset is ~5pt horizontal,
                    // ~8pt vertical — offset the placeholder so it sits on the cursor.
                    .padding(.horizontal, AppSpacing.sm + 5)
                    .padding(.top, AppSpacing.sm + 8)
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
    let action: () -> Void

    init(_ label: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.productAction)
                .foregroundStyle(isEnabled ? AppColor.accentForeground : AppColor.textDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(isEnabled ? AppColor.accent : AppColor.disabledSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

/// Filled secondary action — e.g. `Add Day`, `Next exercise`, `Delete Program`.
/// Supports an optional leading icon and an optional detail line (stacked or
/// inline). Use `tone: .accentSoft` for neutral in-card actions, `.destructive`
/// for delete. Never use as the primary action where `AppPrimaryButton` applies.
struct AppSecondaryButton: View {
    enum Tone {
        /// Neutral control surface, primary text (default — `Add Day`, `Add Exercise`, `Not now`).
        case `default`
        /// Accent-tinted background with accent foreground.
        case accentSoft
        /// No fill, error foreground (`Delete Program`).
        case destructive
    }

    /// How the optional two-line `detail` label is laid out (single-line buttons ignore this).
    enum DetailAlignment {
        case leading
        case center
    }

    /// When `detail` is set: stack title + subtitle vertically, or show **one line** (title + detail side by side).
    enum DetailLayout {
        case stacked
        case inline
    }

    let label: String
    var isEnabled: Bool = true
    var icon: AppIcon? = nil
    /// Trailing segment (e.g. next exercise name). Omit for single-line buttons.
    var detail: String? = nil
    var detailAlignment: DetailAlignment = .leading
    var detailLayout: DetailLayout = .stacked
    var tone: Tone = .default
    /// When `false`, sizes to content with standard horizontal/vertical padding (e.g. compact “Log” on `WorkoutCommandCard`). When `true` (default), stretches to the container width.
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
                                    .font(AppFont.productAction)
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
                                    .font(AppFont.productAction)
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
                            .font(AppFont.productAction)
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

    /// One line: title + detail (e.g. next exercise), centered when `detailAlignment == .center`.
    @ViewBuilder
    private func inlineDetailRow(trimmedDetail: String) -> some View {
        let detailColor = isEnabled ? AppColor.textSecondary : AppColor.textDisabled
        let row = HStack(alignment: .center, spacing: AppSpacing.smd) {
            if let icon {
                icon.image(size: 16, weight: .semibold)
                    .foregroundStyle(foregroundColor)
            }
            Text(label)
                .font(AppFont.productAction)
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
            Text(trimmedDetail)
                .font(AppFont.productAction)
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
            .font(AppFont.productAction)
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
    /// `.compactCapsule` matches Paper today “Day n of m” (node 2P1-0) and `WeeklyProgressStepper` chip height.
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
                .font(AppFont.stepIndicator)
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
        case .muted: return AppColor.mutedFill
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
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

/// Toggleable capsule chip for filter bars (Exercises list, Program library, History).
///
/// Use when a page needs a horizontal row of mutually-toggleable filter pills.
/// Not for status labels — use `AppTag` there. Selected state inverts to
/// `textPrimary` fill; a trailing `×` glyph (when `showsClearGlyphWhenSelected`
/// is true) signals "tap again to clear" without requiring an explicit reset row.
struct AppFilterChip: View {
    let label: String
    let isSelected: Bool
    /// Show an `×` to the right of the label when selected — used on History where
    /// tapping a selected chip clears the filter. Filter bars that reset via a
    /// dedicated "All" pill should leave this false.
    var showsClearGlyphWhenSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Text(label)
                    .font(AppFont.caption.font)
                if isSelected && showsClearGlyphWhenSelected {
                    AppIcon.close.image(size: 10, weight: .bold)
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
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(
            showsClearGlyphWhenSelected && isSelected ? "Tap to clear filter" : "Tap to filter"
        )
    }
}

/// Pill-shaped header action (48pt icon square or 60pt-min text label) used
/// inside `ProductTopBar`. The visible tap area replaces floating text headers
/// so every header action has a clear hit target.
struct ProductTopBarAction: View {
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
                        .font(AppFont.productAction)
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
/// 64pt surface. Compose via `AppScreen(customHeader:)`. Detail flows should stay
/// on `AppNavBar` / native nav bar; this replaces large-title chrome on root tabs.
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
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .tracking(AppFont.productHeadingTracking)
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
        case .md: return AppFont.productHeading
        case .large: return AppFont.productHeading
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

/// Compact multi-step progress chip strip — used for "Week N of M" / "Day N of M"
/// lockups on Today and program cards. Current step renders as a filled black
/// capsule; completed/missed steps become small circles with check/minus glyphs.
struct WeeklyProgressStepper: View {
    struct Step: Identifiable {
        enum State {
            case completed
            case missed
            case current
            case upcoming
        }

        let id: Int
        let label: String
        let state: State
    }

    let steps: [Step]
    /// e.g. `"Week"` on Today hero, `"Day"` on Programs active card (Paper reference).
    var labelPrefix: String = "Week"
    var verticalPadding: CGFloat = AppSpacing.sm

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(steps) { step in
                Group {
                    if step.state == .current {
                        Text("\(labelPrefix) \(step.label)")
                            .font(AppFont.stepIndicator)
                            .foregroundStyle(AppColor.accentForeground)
                            .padding(.horizontal, AppProgressChipMetrics.compactHorizontalPadding)
                            .frame(height: AppProgressChipMetrics.rowHeight)
                            .background(Capsule().fill(AppColor.accent))
                    } else {
                        ZStack {
                            Circle()
                                .fill(backgroundColor(for: step.state))
                                .frame(width: AppProgressChipMetrics.rowHeight, height: AppProgressChipMetrics.rowHeight)

                            switch step.state {
                            case .completed:
                                AppIcon.checkmark.image(size: 10, weight: .bold)
                                    .foregroundStyle(AppColor.textPrimary)
                            case .missed:
                                AppIcon.remove.image(size: 10, weight: .bold)
                                    .foregroundStyle(AppColor.textPrimary)
                            default:
                                Text(step.label)
                                    .font(AppFont.stepIndicator)
                                    .foregroundStyle(foregroundColor(for: step.state))
                            }
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel(for: step))
            }
        }
        .padding(.vertical, verticalPadding)
    }

    private func backgroundColor(for state: Step.State) -> Color {
        switch state {
        case .current:
            return AppColor.accent
        case .completed, .missed, .upcoming:
            return AppColor.mutedFill
        }
    }

    private func foregroundColor(for state: Step.State) -> Color {
        switch state {
        case .current:
            return AppColor.accentForeground
        case .upcoming:
            return AppColor.textSecondary
        case .completed, .missed:
            return AppColor.textPrimary
        }
    }

    private func accessibilityLabel(for step: Step) -> String {
        switch step.state {
        case .completed:
            return "\(labelPrefix) \(step.label), completed"
        case .missed:
            return "\(labelPrefix) \(step.label), missed"
        case .current:
            return "\(labelPrefix) \(step.label), current"
        case .upcoming:
            return "\(labelPrefix) \(step.label), upcoming"
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
                            .font(AppFont.stepIndicator)
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
                                .font(AppFont.compactLabel)
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
                                    .font(AppFont.stepIndicator)
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
                .font(AppFont.numericDisplay)
                .tracking(AppFont.numericDisplayTracking)
                .foregroundStyle(timerCenterForeground)
                .monospacedDigit()

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
        isEmptyHint ? AppFont.caption.font : AppFont.listSecondary.font
    }

    private var subtitleColor: Color {
        isEmptyHint ? AppColor.secondaryLabel : AppColor.textSecondary
    }
}

/// Scrollable, capped-height container for `PreviewListRow`s — used on Today hero
/// and in program active-card previews. Auto-fades the bottom edge when content
/// exceeds `maxHeight` so truncation reads intentionally.
struct PreviewListContainer<Content: View>: View {
    var maxHeight: CGFloat = 228
    /// Vertical gap between rows. Tight by default so the container padding can breathe around the group.
    var rowSpacing: CGFloat = AppSpacing.xs
    /// Inner padding between the container edge and its rows.
    var contentPadding: CGFloat = AppSpacing.md
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat = 0

    private var showsFade: Bool {
        contentHeight > maxHeight
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: rowSpacing) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(contentPadding)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: PreviewListContentHeightKey.self,
                        value: proxy.size.height
                    )
                }
            )
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: maxHeight)
        .onPreferenceChange(PreviewListContentHeightKey.self) { contentHeight = $0 }
        .background(AppColor.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(alignment: .bottom) {
            if showsFade {
                LinearGradient(
                    colors: [AppColor.controlBackground.opacity(0), AppColor.controlBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: AppRadius.md,
                        bottomTrailingRadius: AppRadius.md,
                        style: .continuous
                    )
                )
                .allowsHitTesting(false)
            }
        }
    }
}

private struct PreviewListContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Tall (72pt-min) row optimized for bottom-sheet pickers — "Set 1", "Set 2",
/// with per-row trailing slot for a status badge / current tag. Uses
/// `AppFont.productAction` throughout so sheet copy reads heavier than flat list
/// rows. `showsBorder` injects spacing between rows; set false on the last.
struct SheetListRow<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var titleStyle: TitleStyle = .primary
    var showsBorder: Bool = true
    @ViewBuilder let trailing: () -> Trailing

    enum TitleStyle {
        case primary
        case muted
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppFont.productAction)
                        .foregroundStyle(titleColor)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(AppFont.productAction)
                            .foregroundStyle(subtitleColor)
                    }
                }

                Spacer(minLength: 0)

                trailing()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(minHeight: 72)

            if showsBorder {
                AppDivider(spacing: AppSpacing.sm)
            }
        }
    }

    private var titleColor: Color {
        switch titleStyle {
        case .primary: return AppColor.textPrimary
        case .muted: return AppColor.textSecondary
        }
    }

    private var subtitleColor: Color {
        switch titleStyle {
        case .primary: return AppColor.textSecondary
        case .muted: return AppColor.mutedFill
        }
    }
}

extension SheetListRow where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, titleStyle: TitleStyle = .primary, showsBorder: Bool = true) {
        self.init(title: title, subtitle: subtitle, titleStyle: titleStyle, showsBorder: showsBorder) {
            EmptyView()
        }
    }
}

// MARK: - Organisms

/// Canonical card surface — white fill, continuous 30pt corners, thin stroke,
/// dual lift shadows. The default chrome for any grouped surface. Use `.appCardStyle()`
/// instead when a wrapper type is awkward (e.g. applied to an existing VStack
/// without re-nesting). Never invent inline `.background(...).clipShape(...)` chrome.
struct AppCard<Content: View>: View {
    /// Outer inset for card chrome. System default is `AppSpacing.lg` (24pt) so every
    /// card has consistent breathing room. Compact contexts (list rows, PR rows) can
    /// pass a smaller inset explicitly.
    var contentInset: CGFloat = AppSpacing.lg
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(contentInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .modifier(AppCardElevation())
    }
}

/// Session list row: eyebrow (date), title (template name), optional caption, trailing status (e.g. history badge).
struct AppSessionHighlightCard<Trailing: View>: View {
    let eyebrow: String
    let title: String
    let caption: String?
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        AppCard(contentInset: AppSpacing.lg) {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(eyebrow)
                        .font(AppFont.label.font)
                        .foregroundStyle(AppColor.textSecondary)

                    Text(title)
                        .font(AppFont.title.font)
                        .foregroundStyle(AppColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let caption, !caption.isEmpty {
                        Text(caption)
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                trailing()
            }
        }
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
                        .appCardElevation()
                        .padding(.bottom, AppSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task(id: text) {
                            try? await Task.sleep(for: .seconds(duration))
                            withAnimation(.easeInOut(duration: 0.2)) {
                                message = nil
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: message)
    }
}

extension View {
    /// Show a transient bottom toast bound to a `String?` state.
    func appToast(message: Binding<String?>, duration: TimeInterval = 3.0) -> some View {
        modifier(AppToast(message: message, duration: duration))
    }
}

/// Empty-state card with eyebrow, title, message, and primary action. Used when
/// a feature has no data yet (no program, no sessions). Compose inside `AppScreen`;
/// don't rebuild an eyebrow+title+CTA layout in-place when this fits the shape.
struct EmptyStateCard: View {
    let eyebrow: String
    let title: String
    let message: String
    let buttonLabel: String
    let action: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                Text(eyebrow)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)

                VStack(alignment: .center, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppFont.productHeading)
                        .tracking(AppFont.productHeadingTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(AppFont.productAction)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppPrimaryButton(buttonLabel, action: action)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// Canonical row-list primitive. Two styles:
/// - `.divided` (default): flat list with `AppDivider` between rows — use inside a
///   single shared `AppCard` when rows share a subject (e.g. exercise sets in a
///   session summary).
/// - `.stacked`: each row gets its own `AppCard` with spacing between — use when
///   rows are independently tappable items (e.g. routine list, programs).
///
/// Replaces the former `AppStackedCardList` parallel-implementation. Never add a
/// new list container; extend this style enum if a new variant is genuinely needed.
struct AppDividedList<Data, ID, RowContent>: View
    where Data: RandomAccessCollection, ID: Hashable, RowContent: View
{
    enum Style {
        case divided
        case stacked
    }

    let data: Data
    let id: KeyPath<Data.Element, ID>
    var style: Style = .divided
    var dividerLeading: CGFloat = 0
    var dividerTrailing: CGFloat = 0
    var stackedSpacing: CGFloat = AppSpacing.sm
    @ViewBuilder let content: (Data.Element) -> RowContent

    var body: some View {
        let items = Array(data)
        switch style {
        case .divided:
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
        case .stacked:
            VStack(alignment: .leading, spacing: stackedSpacing) {
                ForEach(items.indices, id: \.self) { index in
                    AppCard {
                        content(items[index])
                    }
                }
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
        self.style = .divided
        self.dividerLeading = dividerLeading
        self.dividerTrailing = dividerTrailing
        self.content = content
    }

    init(
        stacked data: Data,
        spacing: CGFloat = AppSpacing.sm,
        @ViewBuilder content: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = \.id
        self.style = .stacked
        self.stackedSpacing = spacing
        self.content = content
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
                    .font(AppFont.productHeading)
                    .tracking(AppFont.productHeadingTracking)
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
                            .font(AppFont.smallLabel)
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
            .font(AppFont.numericDisplay)
            .tracking(AppFont.numericDisplayTracking)
            .foregroundStyle(AppColor.textPrimary)
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.55)
            .lineLimit(3)
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
            .background(AppColor.barBackground)
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
                .background(AppColor.barBackground)
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

/// Titled group inside an `AppCard` — used in `SettingsView` for "Preferences",
/// "App", etc. For generic grouped content outside settings, compose `AppCard`
/// directly; this wrapper exists only to keep settings copy consistent.
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppFont.sectionHeader.color)

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    content()
                }
            }
        }
    }
}

struct UnitTabItem: View {
    let title: String
    let icon: AppIcon
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                icon.image(size: 24, weight: .semibold)
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(AppFont.stepIndicator)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
            }
            .frame(width: 128, height: 56)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var backgroundColor: Color {
        isActive ? AppColor.mutedFill : .clear
    }

    private var iconColor: Color {
        isActive ? AppColor.textPrimary : AppColor.textSecondary
    }

    private var textColor: Color {
        isActive ? AppColor.textPrimary : AppColor.textSecondary
    }
}

/// Root-shell custom tab bar — replaces native UITabBar visuals so the active
/// tab reads with a muted filled pill. `TabView` still owns state and navigation;
/// this view only provides appearance via `.safeAreaInset(edge: .bottom)`.
struct UnitTabBar: View {
    struct Item: Identifiable {
        let id: String
        let title: String
        let icon: AppIcon
    }

    let items: [Item]
    let selectedID: String
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                UnitTabItem(
                    title: item.title,
                    icon: item.icon,
                    isActive: item.id == selectedID
                ) {
                    onSelect(item.id)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.smd)
        .background(AppColor.background)
    }
}

// MARK: - Template

/// Configures the sticky primary CTA baked into `AppScreen(primaryButton:)`.
/// Pass via `AppScreen(primaryButton: .init(label:action:))` — the screen renders
/// it inside a `.safeAreaInset(edge: .bottom)` so it floats above scroll content.
struct PrimaryButtonConfig {
    let label: String
    var isEnabled: Bool = true
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

/// Page-level template: horizontal padding, optional custom header (`ProductTopBar`)
/// or legacy `AppNavBar`, scrollable body, optional sticky primary CTA. **Every
/// full screen in the app composes through `AppScreen`** — don't rebuild a
/// ScrollView/VStack/nav-bar shell in a feature view. Set `usesOuterScroll: false`
/// for fixed dashboards where inner controls own scrolling.
struct AppScreen<Content: View>: View {
    let title: String?
    let leadingAction: NavAction?
    let trailingAction: NavAction?
    let trailingText: NavTextAction?
    let primaryButton: PrimaryButtonConfig?
    let secondaryButton: SecondaryButtonConfig?
    let customHeader: AnyView?
    var usesCircularTrailingButton: Bool = false
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode? = nil
    var hidesNavigationBar: Bool = false
    var showsNativeNavigationBar: Bool = false
    /// When `false`, the screen does not wrap content in `ScrollView` — use for fixed dashboards where an inner control (e.g. `PreviewListContainer`) owns vertical scrolling.
    var usesOuterScroll: Bool = true
    @ViewBuilder let content: () -> Content

    init(
        title: String? = nil,
        leadingAction: NavAction? = nil,
        trailingAction: NavAction? = nil,
        trailingText: NavTextAction? = nil,
        primaryButton: PrimaryButtonConfig? = nil,
        secondaryButton: SecondaryButtonConfig? = nil,
        customHeader: AnyView? = nil,
        usesCircularTrailingButton: Bool = false,
        navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode? = nil,
        hidesNavigationBar: Bool = false,
        showsNativeNavigationBar: Bool = false,
        usesOuterScroll: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.leadingAction = leadingAction
        self.trailingAction = trailingAction
        self.trailingText = trailingText
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.customHeader = customHeader
        self.usesCircularTrailingButton = usesCircularTrailingButton
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.hidesNavigationBar = hidesNavigationBar
        self.showsNativeNavigationBar = showsNativeNavigationBar
        self.usesOuterScroll = usesOuterScroll
        self.content = content
    }

    private var hasBottomBar: Bool { primaryButton != nil || secondaryButton != nil }

    private var shouldShowNavBar: Bool {
        !hidesNavigationBar && (title != nil || leadingAction != nil || trailingAction != nil || trailingText != nil)
    }

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
                    top: !hidesNavigationBar || showsNativeNavigationBar,
                    bottom: hasBottomBar
                )
            } else {
                paddedMainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if !showsNativeNavigationBar {
                if let customHeader {
                    customHeader
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)
                        .padding(.bottom, AppSpacing.md)
                        .background(AppColor.background)
                } else if shouldShowNavBar {
                    AppNavBar(
                        title: title,
                        leadingAction: leadingAction,
                        trailingAction: trailingAction,
                        trailingText: trailingText
                    )
                    .background(AppColor.barBackground)
                    .padding(.top, AppSpacing.xs)
                    .padding(.bottom, AppSpacing.xs)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if hasBottomBar {
                VStack(spacing: AppSpacing.xs) {
                    if let primaryButton {
                        AppPrimaryButton(
                            primaryButton.label,
                            isEnabled: primaryButton.isEnabled,
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
                .padding(.bottom, AppSpacing.lg)
                .frame(maxWidth: .infinity)
                .background(AppColor.barBackground)
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .toolbar(showsNativeNavigationBar ? .automatic : .hidden, for: .navigationBar)
        .toolbar {
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
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.accent)
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
    /// so both entry points are a single source of truth. Pass `contentInset` to
    /// override the 24pt standard (e.g. `AppSpacing.md` for compact contexts).
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
            // Opaque bar surface so the system back button + title stay visible (`.hidden` can suppress them with UIAppearance).
            .toolbarBackground(AppColor.barBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    /// Canonical style for text-label toolbar buttons (e.g. "History", "Browse").
    /// Matches iOS-native bold top-bar actions so every screen reads the same weight.
    func appToolbarTextStyle() -> some View {
        self.font(AppFont.body.font.weight(.semibold))
    }

    /// iOS-native soft gradient fade at the ScrollView edges where fixed bars
    /// (nav bar, CTA button, tab bar) sit above content. Prevents the sharp-cut
    /// appearance of scrolled content meeting an opaque bar. Both edges default
    /// on — opt out per edge only when no bar exists on that side.
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
/// and a **single sliding** shadowed selected pill (spring-animated) on a track
/// that reads clearly against `AppColor.background`.
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
    @Environment(\.colorScheme) private var colorScheme

    private var pillFill: Color {
        colorScheme == .dark ? AppColor.cardBackground : Color.white
    }

    /// Track fill — `mutedFill` is a step darker than `AppColor.background`
    /// so the track reads as a separated surface without needing a drop shadow.
    private var trackFill: Color { AppColor.mutedFill }

    var body: some View {
        // Track shape — shared between the background fill and the pill clip so
        // the pill's shadow is trimmed to the exact inner curve of the track.
        let trackShape = RoundedRectangle(cornerRadius: trackRadius, style: .continuous)

        ZStack(alignment: .leading) {
            // 1. Track background.
            trackShape.fill(trackFill)

            // 2. Pill (with shadow), clipped to the track shape so the shadow
            //    cannot bleed past any edge — even in a separate render pass.
            GeometryReader { geo in
                let count = max(items.count, 1)
                let segmentWidth = geo.size.width / CGFloat(count)
                let pillHeight = geo.size.height
                let index = items.firstIndex(where: { $0.id == selection.id }) ?? 0
                let pillX = CGFloat(index) * segmentWidth

                RoundedRectangle(cornerRadius: pillRadius, style: .continuous)
                    .fill(pillFill)
                    .frame(width: segmentWidth, height: pillHeight)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12), radius: 4, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 1, x: 0, y: 1)
                    .offset(x: pillX)
                    .animation(.spring(response: 0.34, dampingFraction: 0.84), value: selection.id)
            }
            .padding(trackPadding)
            .compositingGroup()
            .clipShape(trackShape)

            // 3. Labels — drawn above the pill, never clipped so text stays crisp.
            HStack(spacing: 0) {
                ForEach(items) { item in
                    let isSelected = item == selection
                    Button {
                        if !isSelected {
                            selection = item
                        }
                    } label: {
                        Text(title(item))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: height - trackPadding * 2)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(trackPadding)
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

/// Canonical press-feedback button style — 0.96x scale + 150ms easing.
/// Apply to every tappable card or row so "press" reads consistently.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension String {
    func truncatedForNavigationTitle(maxGlyphCount: Int = 34) -> String {
        guard count > maxGlyphCount else { return self }
        let end = index(startIndex, offsetBy: maxGlyphCount)
        return String(self[..<end]).trimmingCharacters(in: .whitespaces) + "…"
    }
}
