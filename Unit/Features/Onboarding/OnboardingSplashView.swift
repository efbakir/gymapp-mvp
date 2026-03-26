//
//  OnboardingSplashView.swift
//  Unit
//
//  Screen 1 — Value prop splash. No data collected.
//  Copy: "Your program. Auto-adjusted every week."
//

import SwiftUI

struct OnboardingSplashView: View {
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
                            .font(AppFont.largeTitle.font)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("adaptive training,\nsimplified.")
                            .font(AppFont.largeTitle.font)
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

                        Text("Build your plan in a few quick steps.")
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
    }
}

#Preview {
    OnboardingSplashView { }
}
