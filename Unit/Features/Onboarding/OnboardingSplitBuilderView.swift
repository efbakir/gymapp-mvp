//
//  OnboardingSplitBuilderView.swift
//  Unit
//
//  Screen 4 — Define training split: number of days and a name for each.
//  Creates the conceptual Split + DayTemplate structure (committed later).
//

import SwiftUI

struct OnboardingSplitBuilderView: View {
    @Environment(OnboardingViewModel.self) private var vm
    var progressStep: Int
    var progressTotal: Int
    var onContinue: () -> Void

    @FocusState private var focusedDay: Int?

    private func dayNameBinding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                guard vm.dayNames.indices.contains(index) else { return "" }
                return vm.dayNames[index]
            },
            set: { newValue in
                guard vm.dayNames.indices.contains(index) else { return }
                vm.dayNames[index] = newValue
            }
        )
    }

    var body: some View {
        @Bindable var vm = vm

        OnboardingShell(
            title: "Your training split",
            ctaLabel: "Continue",
            ctaEnabled: vm.splitIsValid,
            progressStep: progressStep,
            progressTotal: progressTotal,
            onContinue: onContinue
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // Day count stepper — default AppCard inset (lg) matches list card below
                AppCard {
                    HStack {
                        Text("Days per week")
                            .font(AppFont.body.font)
                            .foregroundStyle(AppColor.textPrimary)
                        Spacer()
                        AppStepper(
                            value: "\(vm.dayCount)",
                            onDecrement: { vm.updateDayCount(vm.dayCount - 1) },
                            onIncrement: { vm.updateDayCount(vm.dayCount + 1) }
                        )
                    }
                }

                // Day name fields — same card inset as stepper; divided rows (SessionDetailView pattern)
                AppCard {
                    AppDividedList(data: Array(0..<vm.dayCount), id: \.self) { i in
                        HStack(spacing: AppSpacing.sm) {
                            Text("\(i + 1)")
                                .font(AppFont.caption.font)
                                .foregroundStyle(AppColor.textSecondary)
                                .frame(width: 28, alignment: .leading)

                            TextField("Name", text: dayNameBinding(for: i))
                                .font(AppFont.body.font)
                                .foregroundStyle(AppColor.textPrimary)
                                .focused($focusedDay, equals: i)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .submitLabel(i < vm.dayCount - 1 ? .next : .done)
                                .onSubmit {
                                    if i < vm.dayCount - 1 { focusedDay = i + 1 }
                                    else { focusedDay = nil }
                                }
                        }
                        .padding(.vertical, AppSpacing.md)
                        .contentShape(Rectangle())
                        .onTapGesture { focusedDay = i }
                    }
                }
            }
        }
        .onChange(of: vm.dayCount) { _, newValue in
            guard let focusedDay else { return }
            if focusedDay >= newValue {
                self.focusedDay = max(0, newValue - 1)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingSplitBuilderView(progressStep: 2, progressTotal: 6) { }
            .environment(OnboardingViewModel())
    }
    .tint(AppColor.systemTint)
}
