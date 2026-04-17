//
//  OnboardingSplashView.swift
//  Unit
//
//  Screen 1 — Value prop splash. No data collected.
//  Copy: "your gym notebook, upgraded."
//

import SwiftUI

struct OnboardingSplashView: View {
    var showsDismiss: Bool = false
    var onDismiss: (() -> Void)?
    var onGetStarted: () -> Void

    var body: some View {
        Button(action: onGetStarted) {
            ZStack {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(maxHeight: .infinity)

                    // Brand mark — anchors the screen
                    Text("Unit")
                        .font(AppFont.display)
                        .tracking(AppFont.displayTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.bottom, AppSpacing.lg)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your gym notebook,")
                            .appFont(.largeTitle)
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("upgraded.")
                            .appFont(.largeTitle)
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.xl)

                    Spacer()
                        .frame(maxHeight: .infinity)

                    VStack(spacing: AppSpacing.sm) {
                        Text("Tap anywhere to get started")
                            .font(AppFont.body.font.weight(.semibold))
                            .foregroundStyle(AppColor.textPrimary)

                        Text("Set up your routine in a few quick steps.")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .contentShape(Rectangle())
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

#Preview {
    OnboardingSplashView { }
}
