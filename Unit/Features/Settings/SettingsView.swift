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
    @AppStorage("showOnboardingRestart") private var showOnboardingRestart = false
    @Environment(\.dismiss) private var dismiss

    @State private var showingRestartConfirmation = false

    init(showsCloseButton: Bool = true) {
        self.shouldShowCloseButton = showsCloseButton
    }

    var body: some View {
        AppScreen(showsNativeNavigationBar: true) {
            SettingsSection(title: "Preferences") {
                AppListRow(title: "Weight unit") {
                    Picker("Weight unit", selection: $unitSystem) {
                        Text("kg").tag("kg")
                        Text("lb").tag("lb")
                    }
                    .pickerStyle(.segmented)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
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
                }

                Text("This reopens onboarding. You can choose to keep or replace your current program.")
                    .font(AppFont.caption.font)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if shouldShowCloseButton {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: AppIcon.close.systemName)
                    }
                }
            }
        }
        .tint(AppColor.accent)
        .confirmationDialog(
            "Start onboarding again?",
            isPresented: $showingRestartConfirmation,
            titleVisibility: .visible
        ) {
            Button("Start onboarding again") {
                dismiss()
                showOnboardingRestart = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reopen onboarding. Your current program and workout history will stay in the app.")
        }
    }
}

#Preview {
    SettingsView()
}
