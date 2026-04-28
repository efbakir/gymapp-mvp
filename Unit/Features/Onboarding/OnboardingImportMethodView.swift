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

struct OnboardingOptionCard: View {
    let icon: AppIcon
    let title: String
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: AppSpacing.md) {
                icon.image(size: 18, weight: .semibold)
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 40, height: 40)
                    .background(AppColor.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                Text(title)
                    .font(AppFont.sectionHeader.font)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: 0)

                if let badge {
                    AppTag(text: badge, style: .accent, layout: .compactCapsule)
                }
            }
            .appCardStyle()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationStack {
        OnboardingImportMethodView(progressStep: 1, progressTotal: 6) { _ in }
    }
}
