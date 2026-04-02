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

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Welcome to Unit —")
                            .appFont(.largeTitle)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("your gym notebook,\nupgraded.")
                            .appFont(.largeTitle)
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl + AppSpacing.xl)

                    VStack(spacing: AppSpacing.md) {
                        Text("Tap anywhere to get started")
                            .font(AppFont.sectionHeader.font)
                            .foregroundStyle(AppColor.textSecondary)

                        Text("Set up your routine in a few quick steps.")
                            .font(AppFont.caption.font)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
        }
        .buttonStyle(.plain)
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
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.md)
                .padding(.trailing, AppSpacing.md)
            }
        }
    }
}

#Preview {
    OnboardingSplashView { }
}
