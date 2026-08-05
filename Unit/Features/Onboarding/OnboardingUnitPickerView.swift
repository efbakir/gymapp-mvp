//
//  OnboardingUnitPickerView.swift
//  Unit
//
//  Screen 2 — Pick the weight unit (kg / lb) used everywhere in the app.
//  First choice auto-advances. Returning keeps the choice selected and uses
//  the sticky Continue CTA, matching the other onboarding selection steps.
//

import SwiftUI

struct OnboardingUnitPickerView: View {
    var progressStep: Int
    var progressTotal: Int
    var selectedUnit: String?
    var onSelect: (String) -> Void
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        OnboardingShell(
            title: AppCopy.Onboarding.unitTitle,
            subtitle: AppCopy.Onboarding.unitSubtitle,
            ctaEnabled: selectedUnit != nil,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue,
            onBack: onBack
        ) {
            VStack(spacing: AppSpacing.sm) {
                AppOptionTileCard(
                    iconText: "kg",
                    title: "Kilograms",
                    isSelected: selectedUnit == "kg"
                ) {
                    onSelect("kg")
                }

                AppOptionTileCard(
                    iconText: "lb",
                    title: "Pounds",
                    isSelected: selectedUnit == "lb"
                ) {
                    onSelect("lb")
                }
            }
        }
    }
}

#Preview {
    OnboardingUnitPickerView(
        progressStep: 1,
        progressTotal: 4,
        selectedUnit: "kg",
        onSelect: { _ in },
        onContinue: {},
        onBack: {}
    )
}
