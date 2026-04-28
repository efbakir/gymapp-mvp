//
//  OnboardingUnitPickerView.swift
//  Unit
//
//  Screen 2 — Pick the weight unit (kg / lb) used everywhere in the app.
//  Auto-advances on tap, mirroring OnboardingImportMethodView.
//

import SwiftUI

struct OnboardingUnitPickerView: View {
    var progressStep: Int
    var progressTotal: Int
    var onSelect: (String) -> Void

    /// US locale → lb suggested. UK and metric both prefer kg in gym contexts.
    private var suggestedUnit: String {
        Locale.current.measurementSystem == .us ? "lb" : "kg"
    }

    var body: some View {
        OnboardingShell(
            title: "Pick your unit",
            subtitle: "Choose how weights show up in the app.",
            progressStep: progressStep,
            progressTotal: progressTotal
        ) {
            VStack(spacing: AppSpacing.sm) {
                OnboardingOptionCard(
                    icon: .scalemass,
                    title: "Kilograms (kg)",
                    badge: suggestedUnit == "kg" ? "Suggested" : nil
                ) {
                    onSelect("kg")
                }

                OnboardingOptionCard(
                    icon: .scalemass,
                    title: "Pounds (lb)",
                    badge: suggestedUnit == "lb" ? "Suggested" : nil
                ) {
                    onSelect("lb")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingUnitPickerView(progressStep: 1, progressTotal: 4) { _ in }
    }
}
