//
//  SettingsView.swift
//  Unit
//
//  Lightweight secondary preferences screen launched from Program.
//

import SwiftUI

struct SettingsView: View {
    private let shouldShowCloseButton: Bool

    @AppStorage("unitSystem") private var unitSystem: String = "kg"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss

    @State private var showingRestartConfirmation = false

    init(showsCloseButton: Bool = true) {
        self.shouldShowCloseButton = showsCloseButton
    }

    var body: some View {
        AppScreen(
            title: "Settings",
            leadingAction: shouldShowCloseButton ? NavAction(icon: .close, action: { dismiss() }) : nil
        ) {
            SettingsSection(title: "Preferences") {
                HStack(spacing: AppSpacing.md) {
                    Text("Weight unit")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Picker("Weight unit", selection: $unitSystem) {
                        Text("kg").tag("kg")
                        Text("lb").tag("lb")
                    }
                    .pickerStyle(.segmented)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(minHeight: 44)
            }

            SettingsSection(title: "App") {
                Button(role: .destructive) {
                    showingRestartConfirmation = true
                } label: {
                    Text("Start onboarding again")
                        .font(AppFont.body.font)
                        .foregroundStyle(AppColor.error)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.plain)

                Text("This reopens onboarding without deleting your current data.")
                    .font(AppFont.muted.font)
                    .foregroundStyle(AppFont.muted.color)
            }
        }
        .tint(AppColor.accent)
        .confirmationDialog(
            "Start onboarding again?",
            isPresented: $showingRestartConfirmation,
            titleVisibility: .visible
        ) {
            Button("Start onboarding again", role: .destructive) {
                let onboardingKeys = [
                    OnboardingPreferencesKeys.dayCount,
                    OnboardingPreferencesKeys.dayNames,
                    OnboardingPreferencesKeys.compoundIncrementKg,
                    OnboardingPreferencesKeys.isolationIncrementKg,
                    OnboardingPreferencesKeys.startOption,
                    OnboardingPreferencesKeys.customStartDate
                ]
                for key in onboardingKeys {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                dismiss()
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reopen onboarding. Your current program and workout data will stay in the app.")
        }
    }
}

#Preview {
    SettingsView()
}
