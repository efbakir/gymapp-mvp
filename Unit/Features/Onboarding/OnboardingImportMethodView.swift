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
            subtitle: "Choose how to create your template.",
            progressStep: progressStep,
            progressTotal: progressTotal
        ) {
            VStack(spacing: AppSpacing.sm) {
                OnboardingOptionCard(
                    icon: .clipboard,
                    title: "Paste program"
                ) {
                    onSelect(.paste)
                }

                OnboardingOptionCard(icon: .edit, title: "Build manually") {
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
