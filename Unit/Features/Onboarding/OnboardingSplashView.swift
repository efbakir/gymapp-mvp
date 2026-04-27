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

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Image("BrandLogo")
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96, height: 96)

                    Text("Welcome to")
                        .font(AppFont.splashWelcome)
                        .foregroundStyle(AppColor.secondaryLabel)
                        .padding(.top, AppSpacing.xl)

                    Text("Unit")
                        .font(AppFont.splashTitle)
                        .tracking(AppFont.splashTitleTracking)
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.top, AppSpacing.xxs)

                    VStack(spacing: AppSpacing.xxs) {
                        Text("Your gym notebook -")
                            .font(AppFont.splashWelcome)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColor.textSecondary)

                        Text("upgraded.")
                            .font(AppFont.splashWelcome)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColor.splashAccent)
                    }
                    .padding(.top, AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.xl)

                Spacer()

                AppPrimaryButton("Let's get started!", action: onGetStarted)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
            }
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

#Preview {
    OnboardingSplashView { }
}
