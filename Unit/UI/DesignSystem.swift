//
//  DesignSystem.swift
//  Unit
//
//  Shared UI atoms, molecules, organisms, and screen wrapper.
//

import SwiftUI
import UIKit

// MARK: - Atoms

enum AppColor {
    static let background = Color(uiColor: uicolorAdaptive(light: 0xEBEBEB, dark: 0x0E0F12))
    static let barBackground = Color(uiColor: uicolorAdaptive(light: 0xEBEBEB, dark: 0x13151A))
    static let cardBackground = Color(uiColor: uicolorAdaptive(light: 0xF6F6F6, dark: 0x1D2026))
    static let sheetBackground = Color(uiColor: uicolorAdaptive(light: 0xF6F6F6, dark: 0x21252D))
    static let controlBackground = Color(uiColor: uicolorAdaptive(light: 0xEBEBEB, dark: 0x2C313A))
    static let mutedFill = Color(uiColor: uicolorAdaptive(light: 0xDCDCDC, dark: 0x313640))
    static let disabledSurface = Color(uiColor: uicolorAdaptive(light: 0xC7C7C7, dark: 0x252932))

    static let textPrimary = Color(uiColor: uicolorAdaptive(light: 0x0A0A0A, dark: 0xF5F7FA))
    static let textSecondary = Color(uiColor: uicolorAdaptive(light: 0x919191, dark: 0xB3B8C2))
    static let border = Color(uiColor: uicolorAdaptive(light: 0xDCDCDC, dark: 0x373C47))

    static let accent = Color(uiColor: uicolorAdaptive(light: 0x0A0A0A, dark: 0xF3F4F6))
    static let accentForeground = Color(uiColor: uicolorAdaptive(light: 0xF6F6F6, dark: 0x111317))
    static let accentSoft = Color(uiColor: uicolorAccentSoft())
    static let success = Color(uiColor: uicolorAdaptive(light: 0x34C759, dark: 0x30D158))
    static let warning = Color(uiColor: uicolorAdaptive(light: 0xFF9500, dark: 0xFF9F0A))
    static let error = Color(uiColor: uicolorAdaptive(light: 0xFF3B30, dark: 0xFF453A))

    static let scrim = Color(uiColor: uicolorScrim())

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

enum AppFont {
    case largeTitle
    case title
    case sectionHeader
    case body
    case label
    case caption
    case muted

    var font: Font {
        switch self {
        case .largeTitle:
            return .custom("Inter-Bold", size: 22)
        case .title:
            return .custom("Inter-SemiBold", size: 20)
        case .sectionHeader:
            return .custom("Inter-SemiBold", size: 17)
        case .body:
            return .custom("Inter-Medium", size: 17)
        case .label:
            return .custom("Inter-SemiBold", size: 17)
        case .caption, .muted:
            return .custom("Inter-Medium", size: 12)
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

    static let overline: Font = .custom("Inter-SemiBold", size: 10)
    static let smallLabel: Font = .custom("Inter-Medium", size: 11)
    static let display: Font = .custom("Inter-Bold", size: 36)
    static let numericDisplay: Font = .custom("Inter-Bold", fixedSize: 36)
    static let numericLarge: Font = .custom("Inter-Bold", fixedSize: 28)
    static let compactLabel: Font = .custom("Inter-SemiBold", size: 12)
    static let stepIndicator: Font = .custom("Inter-SemiBold", size: 14)
    static let productHeading: Font = .custom("Inter-SemiBold", size: 24)
    static let productAction: Font = .custom("Inter-SemiBold", size: 17)

    /// Tracking for static font properties (display-level gets tighter spacing).
    static let displayTracking: CGFloat = -0.6
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

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let card: CGFloat = 20
    static let sheet: CGFloat = 40
}

/// Shared sizing for day/week steppers and compact day badges (Paper e.g. node 2P1-0).
enum AppProgressChipMetrics {
    static let rowHeight: CGFloat = 20
    static var compactHorizontalPadding: CGFloat { AppSpacing.sm }
}

struct AppDivider: View {
    @Environment(\.pixelLength) private var pixelLength

    var body: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(height: pixelLength)
            .frame(maxWidth: .infinity)
    }
}

enum AppShadow {
    static func sheetLift(_ colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, y: CGFloat) {
        colorScheme == .dark
            ? (Color.black.opacity(0.58), 28, -12)
            : (Color.black.opacity(0.18), 26, -12)
    }
}

enum AppIcon: String {
    case back = "chevron.left"
    case chevronRight = "chevron.right"
    case forward = "arrow.right"
    case close = "xmark"
    case add = "plus"
    case remove = "minus"
    case edit = "pencil"
    case editLine = "pencil.line"
    case trash = "trash"
    case swap = "arrow.triangle.2.circlepath"
    case clearField = "xmark.circle"
    case search = "magnifyingglass"
    case home = "house.fill"
    case program = "square.and.pencil"
    case todayTab = "dumbbell.fill"
    case settings = "gearshape.fill"
    case settingsOutline = "gearshape"
    case checkmarkFilled = "checkmark.circle.fill"
    case checkmark = "checkmark"
    case xmarkFilled = "xmark.circle.fill"
    case failCircle = "xmark.square.fill"
    case timer = "timer"
    case play = "play.fill"
    case pause = "pause.fill"
    case list = "list.bullet"
    case calendarClock = "calendar.badge.clock"
    case calendarPlain = "calendar"
    case cloud = "icloud.fill"
    case bolt = "bolt.fill"
    case progression = "arrow.up.right.circle.fill"
    case target = "target"
    case chart = "chart.line.uptrend.xyaxis"
    case deload = "arrow.down.circle.fill"
    case addCircle = "plus.circle.fill"
    case sliders = "slider.horizontal.3"
    case photo = "photo"
    case dumbbell = "dumbbell"
    case trophy = "trophy"
    case reorder = "line.3.horizontal"
    case applelogo = "applelogo"
    case camera = "camera"
    case clipboard = "doc.on.clipboard"
    case keyboard = "keyboard"
    case minusCircle = "minus.circle"
    case circle = "circle"

    var systemName: String { rawValue }

    func image(size: CGFloat = 17, weight: Font.Weight = .semibold) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight))  // SF Symbols require system font
    }
}

extension Double {
    var weightString: String {
        self == floor(self) ? "\(Int(self))" : String(format: "%.1f", self)
    }
}

// MARK: - Molecules

struct NavAction {
    let icon: AppIcon
    let action: () -> Void
}

struct NavTextAction {
    let label: String
    let action: () -> Void
}

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

                if let trailingText {
                    Button(action: trailingText.action) {
                        Text(trailingText.label)
                            .font(AppFont.label.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                } else if let trailingAction {
                    iconButton(trailingAction)
                } else {
                    Spacer().frame(width: 44)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, AppSpacing.sm)
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
}

struct AppNavBarWithTextTrailing: View {
    let title: String?
    let leadingAction: NavAction?
    let trailingAction: NavAction?
    let trailingText: NavTextAction

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

                HStack(spacing: AppSpacing.xs) {
                    if let trailingAction {
                        iconButton(trailingAction)
                    }

                    Button(action: trailingText.action) {
                        Text(trailingText.label)
                            .font(AppFont.label.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, AppSpacing.sm)
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
}

struct AppListRow<Trailing: View>: View {
    let title: String
    let subtitle: String?
    let leadingIcon: AppIcon?
    @ViewBuilder let trailing: () -> Trailing

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: AppIcon? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
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
        .padding(.vertical, AppSpacing.sm)
    }
}

extension AppListRow where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, leadingIcon: AppIcon? = nil) {
        self.init(title: title, subtitle: subtitle, leadingIcon: leadingIcon) {
            EmptyView()
        }
    }
}

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
                .foregroundStyle(isEnabled ? AppColor.accentForeground : AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isEnabled ? AppColor.accent : AppColor.disabledSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

struct AppSecondaryButton: View {
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
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isEnabled ? AppColor.controlBackground : AppColor.disabledSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
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
            .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}

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
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

struct AppTag: View {
    let text: String
    var style: Style = .default
    /// `.compactCapsule` matches Paper today “Day n of m” (node 2P1-0) and `WeeklyProgressStepper` chip height.
    var layout: Layout = .regular

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
                Text(text)
                    .font(AppFont.stepIndicator)
                    .foregroundStyle(foregroundColor)
                    .padding(.horizontal, AppSpacing.smd)
                    .padding(.vertical, AppSpacing.sm)
                    .background(backgroundColor)
                    .clipShape(Capsule())
            case .compactCapsule:
                Text(text)
                    .font(AppFont.stepIndicator)
                    .foregroundStyle(foregroundColor)
                    .padding(.horizontal, AppProgressChipMetrics.compactHorizontalPadding)
                    .frame(height: AppProgressChipMetrics.rowHeight)
                    .background(backgroundColor)
                    .clipShape(Capsule())
            }
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default: return AppColor.textPrimary
        case .accent: return AppColor.accentForeground
        case .success: return AppColor.success
        case .warning: return AppColor.warning
        case .error: return AppColor.error
        case .muted: return AppColor.textSecondary
        case .custom(let fg, _): return fg
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return AppColor.controlBackground
        case .accent: return AppColor.accent
        case .success: return AppColor.success.opacity(0.16)
        case .warning: return AppColor.warning.opacity(0.18)
        case .error: return AppColor.error.opacity(0.16)
        case .muted: return AppColor.mutedFill
        case .custom(_, let bg): return bg
        }
    }
}

struct IconChip: View {
    let icon: AppIcon
    var style: Style = .default

    enum Style {
        case `default`
        case accent
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 32, height: 32)

            icon.image(size: 14, weight: .semibold)
                .foregroundStyle(iconColor)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return AppColor.controlBackground
        case .accent: return AppColor.accent
        }
    }

    private var iconColor: Color {
        switch style {
        case .default: return AppColor.textPrimary
        case .accent: return AppColor.accentForeground
        }
    }
}

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

struct IconSquareButton: View {
    enum Style: Equatable {
        case `default`
        case selected
        case muted
        case disabled
    }

    let icon: AppIcon
    var style: Style = .default
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            icon.image(size: 16, weight: .semibold)
                .foregroundStyle(iconColor)
                .frame(width: 48, height: 48)
                .background(backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(action == nil || style == .disabled)
    }

    private var iconColor: Color {
        switch style {
        case .default, .muted:
            return AppColor.textPrimary
        case .selected:
            return AppColor.accentForeground
        case .disabled:
            return AppColor.textSecondary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default, .muted:
            return AppColor.controlBackground
        case .selected:
            return AppColor.accent
        case .disabled:
            return AppColor.disabledSurface
        }
    }

    private var borderColor: Color {
        switch style {
        case .selected:
            return AppColor.accent
        default:
            return AppColor.border
        }
    }
}

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
        switch step.state {
        case .completed:
            return "Set \(step.label), completed"
        case .failed:
            return "Set \(step.label), below target"
        case .current:
            return "Set \(step.label), current"
        case .upcoming:
            return "Set \(step.label), upcoming"
        case .disabled:
            return "Set \(step.label), unavailable"
        }
    }
}

struct MetricDisplay: View {
    enum Style {
        case metric
        case subdued
        case placeholder
    }

    let value: String
    var supportingText: String? = nil
    var style: Style = .metric

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(valueFont)
                .tracking(valueTracking)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let supportingText, !supportingText.isEmpty {
                Text(supportingText)
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var valueFont: Font {
        switch style {
        case .metric:
            return AppFont.numericDisplay
        case .subdued:
            return AppFont.numericLarge
        case .placeholder:
            return AppFont.title.font
        }
    }

    private var valueTracking: CGFloat {
        switch style {
        case .metric:
            return AppFont.numericDisplayTracking
        case .subdued:
            return AppFont.numericLargeTracking
        case .placeholder:
            return 0
        }
    }

    private var valueColor: Color {
        switch style {
        case .metric:
            return AppColor.textPrimary
        case .subdued, .placeholder:
            return AppColor.textSecondary
        }
    }
}

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
        HStack(spacing: AppSpacing.sm) {
            adjustButton(icon: .remove, action: onDecrease)

            Button(action: { onToggle?() }) {
                HStack(spacing: AppSpacing.sm) {
                    Text(timeText)
                        .font(AppFont.numericLarge)
                        .tracking(AppFont.numericLargeTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .monospacedDigit()

                    if let indicatorIcon {
                        indicatorIcon.image(size: 16, weight: .semibold)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                .frame(height: 56)
                .padding(.horizontal, AppSpacing.md)
                .background(showsTimerBackground ? AppColor.controlBackground : .clear)
                .clipShape(Capsule())
                .contentShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(onToggle == nil || state == .disabled)

            adjustButton(icon: .add, action: onIncrease)
        }
        .opacity(state == .disabled ? 0.5 : 1)
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

    private var showsTimerBackground: Bool {
        state == .running
    }

    private func adjustButton(icon: AppIcon, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            icon.image(size: 26, weight: .semibold)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 56, height: 56)
                .background(AppColor.controlBackground)
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(action == nil || state == .disabled)
    }
}

struct ExercisePreviewItem: View {
    let title: String
    let detail: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFont.productAction)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(detail)
                    .font(AppFont.productAction)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: true, vertical: false)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

struct ExercisePreviewStrip: View {
    struct Item: Identifiable {
        let id: String
        let title: String
        let detail: String

        init(id: String? = nil, title: String, detail: String) {
            self.id = id ?? "\(title)-\(detail)"
            self.title = title
            self.detail = detail
        }
    }

    let items: [Item]
    var onSelect: ((Item) -> Void)? = nil

    @State private var contentWidth: CGFloat = 0
    @State private var viewportWidth: CGFloat = 0

    private var showsOverflowFade: Bool {
        contentWidth > viewportWidth + 1
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.lg) {
                ForEach(items) { item in
                    ExercisePreviewItem(title: item.title, detail: item.detail) {
                        onSelect?(item)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ExercisePreviewContentWidthKey.self, value: proxy.size.width)
                }
            )
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: ExercisePreviewViewportWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(ExercisePreviewContentWidthKey.self) { contentWidth = $0 }
        .onPreferenceChange(ExercisePreviewViewportWidthKey.self) { viewportWidth = $0 }
        .background(AppColor.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(alignment: .trailing) {
            if showsOverflowFade {
                LinearGradient(
                    colors: [AppColor.controlBackground.opacity(0), AppColor.controlBackground],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 20)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .allowsHitTesting(false)
            }
        }
    }
}

private struct ExercisePreviewContentWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ExercisePreviewViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - PreviewListRow + PreviewListContainer

struct PreviewListRow: View {
    enum Style {
        /// Default: dark title for exercise names (Today card, etc.).
        case standard
        /// Muted exercise list (Paper): title `#919191`, subtitle `#C7C7C7` light — Programs active card & Today hero preview.
        case programRoutine
    }

    let title: String
    let subtitle: String
    var style: Style = .standard

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(titleColor)

            Text(subtitle)
                .font(subtitleFont)
                .foregroundStyle(subtitleColor)
        }
        .padding(.vertical, AppSpacing.sm)
    }

    private var titleColor: Color {
        switch style {
        case .standard:
            return AppColor.textPrimary
        case .programRoutine:
            return AppColor.textSecondary
        }
    }

    private var subtitleFont: Font {
        switch style {
        case .standard:
            return AppFont.caption.font
        case .programRoutine:
            return .custom("Inter-Medium", size: 12)
        }
    }

    private var subtitleColor: Color {
        switch style {
        case .standard:
            return AppColor.textSecondary
        case .programRoutine:
            return AppColor.disabledSurface
        }
    }
}

struct PreviewListContainer<Content: View>: View {
    var maxHeight: CGFloat = 228
    /// Vertical gap between rows (Paper program card uses `AppSpacing.lg`).
    var rowSpacing: CGFloat = AppSpacing.sm
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
            .padding(AppSpacing.md)
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

struct SheetHeader: View {
    let title: String
    var onDone: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            // Invisible spacer matching Done button width for centering
            Color.clear
                .frame(width: 60, height: 48)

            Spacer()

            Text(title)
                .font(AppFont.productHeading)
                .tracking(AppFont.productHeadingTracking)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            if let onDone {
                Button(action: onDone) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 60, height: 48)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 60, height: 48)
            }
        }
        .padding(.top, AppSpacing.sm)
    }
}

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
                CardSectionDivider()
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

struct AppCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

struct CardSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.background)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
}

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

struct HeroWorkoutCard: View {
    let progressSteps: [WeeklyProgressStepper.Step]
    let title: String
    let subtitle: String
    let previewItems: [ExercisePreviewStrip.Item]
    var primaryLabel: String = "Start"
    var onPreviewTap: (() -> Void)? = nil
    let onPrimaryAction: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .center, spacing: AppSpacing.md) {
                WeeklyProgressStepper(steps: progressSteps)

                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.xs) {
                        Text(title)
                            .font(AppFont.productHeading)
                            .tracking(AppFont.productHeadingTracking)
                            .foregroundStyle(AppColor.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.lg)

                    if !previewItems.isEmpty {
                        ExercisePreviewStrip(items: previewItems) { _ in
                            onPreviewTap?()
                        }
                    }
                }

                AppPrimaryButton(primaryLabel, action: onPrimaryAction)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

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
    var state: State = .active
    var primaryLabel: String = "Done"
    var onPrimaryAction: (() -> Void)? = nil
    var onSecondaryAction: (() -> Void)? = nil
    var timerValue: String? = nil
    var timerState: RestTimerControl.State = .idle
    var onTimerDecrease: (() -> Void)? = nil
    var onTimerToggle: (() -> Void)? = nil
    var onTimerIncrease: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Top section: stepper + exercise info + action button
            VStack(alignment: .center, spacing: AppSpacing.md) {
                SetProgressIndicator(steps: progressSteps)

                VStack(spacing: AppSpacing.sm) {
                    Text(exerciseName)
                        .font(AppFont.productHeading)
                        .tracking(AppFont.productHeadingTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if onSecondaryAction != nil {
                        Button(action: { onSecondaryAction?() }) {
                            HStack(spacing: AppSpacing.xs) {
                                Text(metricValue)
                                    .font(AppFont.productAction)

                                AppIcon.edit.image(size: 15, weight: .semibold)
                            }
                            .foregroundStyle(AppColor.textSecondary)
                            .frame(minHeight: 44)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel("Adjust set")
                    } else {
                        Text(metricValue)
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, AppSpacing.md)

                if state != .completed {
                    AppPrimaryButton(
                        primaryLabel,
                        isEnabled: state == .active && onPrimaryAction != nil,
                        action: { onPrimaryAction?() }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)

            // Bottom section: timer
            if let timerValue {
                CardSectionDivider()

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
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }
}

struct ExerciseCommandCard: View {
    enum State: Equatable {
        case active
        case completed
        case disabled
    }

    let progressSteps: [SetProgressIndicator.Step]
    let exerciseName: String
    let setLabel: String
    let metricValue: String
    var metricSupportingText: String? = nil
    var metricStyle: MetricDisplay.Style = .metric
    var state: State = .active
    var primaryLabel: String = "Done"
    var onPrimaryAction: (() -> Void)? = nil
    var onSecondaryAction: (() -> Void)? = nil

    var body: some View {
        WorkoutCommandCard(
            progressSteps: progressSteps,
            exerciseName: exerciseName,
            metricValue: metricValue,
            metricSupportingText: metricSupportingText ?? setLabel,
            state: mappedState,
            primaryLabel: primaryLabel,
            onPrimaryAction: onPrimaryAction,
            onSecondaryAction: onSecondaryAction
        )
    }

    private var mappedState: WorkoutCommandCard.State {
        switch state {
        case .active:
            return .active
        case .completed:
            return .completed
        case .disabled:
            return .disabled
        }
    }
}

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
                AppCard {
                    content
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
            }
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
                Button(action: { onAdvance?() }) {
                    HStack(spacing: AppSpacing.sm) {
                        Text("Next")
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.textPrimary)

                        Text(subtitle)
                            .font(AppFont.productAction)
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(AppColor.mutedFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(onAdvance == nil)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
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

struct ExerciseRow: View {
    let name: String
    let weightText: String
    let repsText: String
    var isBodyweight: Bool = false

    var body: some View {
        AppListRow(title: name) {
            Text(displayValue)
                .font(AppFont.label.font)
                .foregroundStyle(AppColor.textPrimary)
                .monospacedDigit()
        }
    }

    private var displayValue: String {
        let load = isBodyweight && (weightText == "0kg" || weightText == "0lb") ? "BW" : weightText
        return "\(load) × 1 × \(repsText)"
    }
}

struct DayCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let isExpanded: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: isExpanded ? AppSpacing.md : 0) {
                Button(action: action) {
                    AppListRow(title: title, subtitle: subtitle) {
                        EmptyView()
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    content()
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.sectionHeader.font)
                .foregroundStyle(AppFont.sectionHeader.color)

            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    content()
                }
            }
        }
    }
}

private let appScreenScrollCoordinateSpace = "AppScreenScroll"

struct AppTabHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder let trailing: () -> Trailing

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named(appScreenScrollCoordinateSpace)).minY
            let collapseProgress = min(max((AppSpacing.md - minY) / 52, 0), 1)

            HStack(alignment: .center, spacing: AppSpacing.md) {
                Text(title)
                    .font(AppFont.display)
                    .tracking(AppFont.displayTracking)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: AppSpacing.sm) {
                    trailing()
                }
            }
            .offset(y: -collapseProgress * 8)
            .scaleEffect(1 - (collapseProgress * 0.06), anchor: .topLeading)
            .opacity(1.0 - (collapseProgress * 0.08))
            .animation(.spring(response: 0.28, dampingFraction: 0.9), value: collapseProgress)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 56)
    }
}

extension AppTabHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

struct AppHeaderIconButton: View {
    let icon: AppIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColor.controlBackground)
                    .frame(width: 32, height: 32)

                icon.image(size: 15, weight: .semibold)
                    .foregroundStyle(AppColor.textPrimary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
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
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: -1)
    }
}

// MARK: - Template

struct PrimaryButtonConfig {
    let label: String
    var isEnabled: Bool = true
    let action: () -> Void
}

struct AppScreen<Content: View>: View {
    let title: String?
    let leadingAction: NavAction?
    let trailingAction: NavAction?
    let trailingText: NavTextAction?
    let primaryButton: PrimaryButtonConfig?
    let customHeader: AnyView?
    var usesCircularTrailingButton: Bool = false
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode? = nil
    var hidesNavigationBar: Bool = false
    var showsNativeNavigationBar: Bool = false
    @ViewBuilder let content: () -> Content

    init(
        title: String? = nil,
        leadingAction: NavAction? = nil,
        trailingAction: NavAction? = nil,
        trailingText: NavTextAction? = nil,
        primaryButton: PrimaryButtonConfig? = nil,
        customHeader: AnyView? = nil,
        usesCircularTrailingButton: Bool = false,
        navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode? = nil,
        hidesNavigationBar: Bool = false,
        showsNativeNavigationBar: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.leadingAction = leadingAction
        self.trailingAction = trailingAction
        self.trailingText = trailingText
        self.primaryButton = primaryButton
        self.customHeader = customHeader
        self.usesCircularTrailingButton = usesCircularTrailingButton
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.hidesNavigationBar = hidesNavigationBar
        self.showsNativeNavigationBar = showsNativeNavigationBar
        self.content = content
    }

    private var shouldShowNavBar: Bool {
        !hidesNavigationBar && (title != nil || leadingAction != nil || trailingAction != nil || trailingText != nil)
    }

    /// Max content width — keeps the mobile layout on iPad / Mac.
    private var maxContentWidth: CGFloat { 430 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                content()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, showsNativeNavigationBar ? AppSpacing.sm : (customHeader == nil ? AppSpacing.md : AppSpacing.sm))
            .padding(.bottom, primaryButton != nil ? 100 : AppSpacing.md)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .coordinateSpace(name: appScreenScrollCoordinateSpace)
        .appScrollEdgeSoftTop(enabled: !hidesNavigationBar || showsNativeNavigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            if !showsNativeNavigationBar {
                if let customHeader {
                    VStack(spacing: 0) {
                        customHeader
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, AppSpacing.xs)
                            .background(AppColor.background)

                        ScrollEdgeFadeView(edge: .bottomOfHeader, surfaceColor: AppColor.background)
                    }
                } else if shouldShowNavBar {
                    VStack(spacing: 0) {
                        Group {
                            if let trailingText, trailingAction != nil {
                                AppNavBarWithTextTrailing(
                                    title: title,
                                    leadingAction: leadingAction,
                                    trailingAction: trailingAction,
                                    trailingText: trailingText
                                )
                            } else {
                                AppNavBar(
                                    title: title,
                                    leadingAction: leadingAction,
                                    trailingAction: trailingAction,
                                    trailingText: trailingText
                                )
                            }
                        }
                        .background(AppColor.barBackground)
                        .padding(.top, AppSpacing.xs)
                        .padding(.bottom, AppSpacing.xs)

                        ScrollEdgeFadeView(edge: .bottomOfHeader)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let primaryButton {
                VStack(spacing: 0) {
                    ScrollEdgeFadeView(edge: .topOfFooter)

                    AppPrimaryButton(
                        primaryButton.label,
                        isEnabled: primaryButton.isEnabled,
                        action: primaryButton.action
                    )
                    .frame(maxWidth: maxContentWidth - AppSpacing.md * 2)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(AppColor.barBackground)
                }
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .toolbar(showsNativeNavigationBar ? .automatic : .hidden, for: .navigationBar)
    }
}

// MARK: - Scroll Edge Fade

/// Soft gradient overlay that sits at the edge of a fixed surface (header, tab bar, bottom sheet)
/// to smooth the transition where scrollable content disappears underneath.
///
/// Usage: place as an overlay or adjacent view on the fixed surface side that faces the scroll content.
///
///     .overlay(alignment: .bottom) {
///         ScrollEdgeFade(.bottomOfHeader)
///     }
///
enum ScrollEdgeFade {
    /// Fade below a fixed top surface (header / nav bar) — transparent at bottom.
    case bottomOfHeader
    /// Fade above a fixed bottom surface (tab bar / CTA bar) — transparent at top.
    case topOfFooter

    /// Default fade height. Tuned to feel subtle, not decorative.
    static let defaultHeight: CGFloat = AppSpacing.lg          // 24pt

    /// Slightly taller variant for surfaces that sit over busier content.
    static let extendedHeight: CGFloat = AppSpacing.xl         // 32pt
}

struct ScrollEdgeFadeView: View {
    let edge: ScrollEdgeFade
    var height: CGFloat = ScrollEdgeFade.defaultHeight
    var surfaceColor: Color = AppColor.barBackground

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .frame(height: height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var colors: [Color] {
        switch edge {
        case .bottomOfHeader:
            return [surfaceColor.opacity(0.98), surfaceColor.opacity(0)]
        case .topOfFooter:
            return [surfaceColor.opacity(0), surfaceColor.opacity(0.98)]
        }
    }

    private var startPoint: UnitPoint {
        switch edge {
        case .bottomOfHeader: return .top
        case .topOfFooter:    return .top
        }
    }

    private var endPoint: UnitPoint {
        switch edge {
        case .bottomOfHeader: return .bottom
        case .topOfFooter:    return .bottom
        }
    }
}

// MARK: - Shared modifiers

extension View {
    func appInputFieldStyle(
        height: CGFloat = 48,
        horizontalPadding: CGFloat = AppSpacing.md,
        lineWidth: CGFloat = 0.5
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
    }

    func appCardStyle() -> some View {
        self
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    func appBottomSheetChrome() -> some View {
        modifier(AppBottomSheetChromeModifier())
    }

    func navigationBarTitleTruncated(_ title: String, maxGlyphCount: Int = 34) -> some View {
        navigationTitle(title.truncatedForNavigationTitle(maxGlyphCount: maxGlyphCount))
    }

    func appNavigationBarChrome() -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    func appScrollEdgeSoftTop(enabled: Bool) -> some View {
        if enabled {
            if #available(iOS 18.0, *) {
                self.scrollEdgeEffectStyle(.soft, for: .top)
            } else {
                self
            }
        } else {
            self
        }
    }

    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

private struct AppBottomSheetChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: AppSpacing.md)
            }
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(AppRadius.sheet)
            .presentationBackground(AppColor.background)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
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
