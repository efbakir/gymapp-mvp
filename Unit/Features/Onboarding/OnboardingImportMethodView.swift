//
//  OnboardingImportMethodView.swift
//  Unit
//
//  Screen 3 — Choose how to bring an existing program into onboarding.
//

import SwiftUI

struct OnboardingImportMethodView: View {
    var progressStep: Int
    var progressTotal: Int
    var onSelect: (OnboardingViewModel.ImportMethod) -> Void

    var body: some View {
        OnboardingShell(
            title: "Add your program",
            progressStep: progressStep,
            progressTotal: progressTotal
        ) {
            VStack(spacing: AppSpacing.sm) {
                OnboardingOptionCard(
                    icon: .camera,
                    title: "Take a photo",
                    subtitle: "Snap your sheet and let Unit read it."
                ) {
                    onSelect(.photo)
                }

                OnboardingOptionCard(
                    icon: .clipboard,
                    title: "Paste text",
                    subtitle: "Paste your plan and let Unit split it up."
                ) {
                    onSelect(.paste)
                }

                OnboardingOptionCard(
                    icon: .edit,
                    title: "Add by hand",
                    subtitle: "Type your days and exercises yourself."
                ) {
                    onSelect(.manual)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingImportMethodView(progressStep: 1, progressTotal: 6) { _ in }
    }
}
