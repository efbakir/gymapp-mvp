//
//  OnboardingSplashView.swift
//  Unit
//
//  Screen 1 — Value prop splash. No data collected.
//

import SwiftUI

struct OnboardingSplashView: View {
    var showsDismiss: Bool = false
    var onDismiss: (() -> Void)?
    var onGetStarted: () -> Void

    private static let logoSide: CGFloat = 144

    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func staggered(_ index: Int) -> some ViewModifier {
        StaggeredEntry(
            index: index,
            hasAppeared: hasAppeared,
            reduceMotion: reduceMotion
        )
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Dark `BrandLogo` on chrome-matched tile (no shadow). `barBackground` is nearest surface to `background` in the token set.
                    Image("BrandLogo")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: Self.logoSide, height: Self.logoSide)
                        .background(AppColor.barBackground)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: AppRadius.appIconHomeScreenCornerRadius(sideLength: Self.logoSide),
                                style: .continuous
                            )
                        )
                        .modifier(staggered(0))

                    VStack(spacing: AppSpacing.xxs) {
                        Text("Welcome to")
                            .font(AppFont.splashWelcome)
                            .foregroundStyle(AppColor.secondaryLabel)

                        Text("Unit")
                            .font(AppFont.splashTitle)
                            .tracking(AppFont.splashTitleTracking)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .padding(.top, AppSpacing.xl)
                    .modifier(staggered(1))

                    HStack(spacing: 4) {
                        Text("Your gym notebook –")
                            .foregroundStyle(AppColor.secondaryLabel)
                        Text("upgraded.")
                            .foregroundStyle(AppColor.splashAccent)
                    }
                    .font(AppFont.splashWelcome)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, AppSpacing.xl)
                    .modifier(staggered(2))
                }
                .padding(.horizontal, AppSpacing.xl)

                Spacer()

                AppPrimaryButton("Get started", action: onGetStarted)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
                    .modifier(staggered(3))
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topTrailing) {
            if showsDismiss {
                Button {
                    onDismiss?()
                } label: {
                    AppIcon.close.image(size: 16, weight: .semibold)
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, AppSpacing.md)
                .padding(.trailing, AppSpacing.md)
            }
        }
    }
}

/// Splash-only entry stagger: each block fades + translates in with an 80ms-per-index delay.
/// Honors Reduce Motion. Kept file-private — promote to DesignSystem.swift if a second screen needs it.
private struct StaggeredEntry: ViewModifier {
    let index: Int
    let hasAppeared: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared || reduceMotion ? 0 : 8)
            .animation(
                reduceMotion
                    ? .easeOut(duration: 0.2)
                    : .easeOut(duration: 0.4).delay(Double(index) * 0.08),
                value: hasAppeared
            )
    }
}

#Preview {
    OnboardingSplashView { }
}
