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
                    // `BrandLogo` on chrome-matched tile (no shadow). Opacity softens the mark vs pure black.
                    Image("BrandLogo")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .opacity(0.78)
                        .frame(width: Self.logoSide, height: Self.logoSide)
                        .background(AppColor.barBackground)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: AppRadius.splashLogoTileCornerRadius(sideLength: Self.logoSide),
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

                    Text("Your upgraded gym notebook")
                        .font(AppFont.splashWelcome)
                        .foregroundStyle(AppColor.secondaryLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppSpacing.xl)
                        .modifier(staggered(2))
                }
                .padding(.horizontal, AppSpacing.xl)

                Spacer()

                AppPrimaryButton("Set up program", action: onGetStarted)
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
