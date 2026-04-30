//
//  SettingsView.swift
//  Unit
//
//  Lightweight secondary preferences screen launched from Program.
//

import SwiftUI

private enum SettingsWeightUnit: String, CaseIterable, Identifiable, Hashable {
    case kg
    case lb

    var id: String { rawValue }
}

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
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSection(title: "Preferences", contentInset: AppSpacing.sm) {
                    AppListRow(title: "Weight unit") {
                        AppSegmentedControl(
                            selection: Binding(
                                get: { SettingsWeightUnit(rawValue: unitSystem) ?? .kg },
                                set: { unitSystem = $0.rawValue }
                            ),
                            items: SettingsWeightUnit.allCases,
                            title: { $0.rawValue }
                        )
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
                        .buttonStyle(ScaleButtonStyle())
                    }

                    Text("Walks through setup again. Your program and history stay.")
                        .font(AppFont.caption.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, AppSpacing.md)
                }
            }
            .appScreenEnter()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if shouldShowCloseButton {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Label(AppCopy.Nav.close, systemImage: AppIcon.close.systemName)
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel(AppCopy.Nav.close)
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
            Button(AppCopy.Nav.cancel, role: .cancel) { }
        } message: {
            Text("Your program and history stay.")
        }
    }
}

#Preview {
    SettingsView()
}
