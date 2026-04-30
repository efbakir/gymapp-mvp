//
//  OnboardingView.swift
//  Unit
//
//  Root coordinator for the onboarding flow.
//
//  Routing is state-driven: ContentView shows this view when there is no
//  program data (new user) or when the user explicitly requests a restart
//  from Settings. The view never sets a "hasCompletedOnboarding" boolean —
//  instead, the commit writes real data (Split, DayTemplate, etc.) and
//  ContentView derives the next screen from that data.
//
//  Step swapping uses `OnboardingFlow` (defined below) instead of
//  `NavigationStack`. NavigationStack push slides the whole view as one
//  opaque rect, so the Milk page appears to slide between steps even
//  though every step shares the same surface. `OnboardingFlow` owns one
//  fixed Milk surface and slides only the step content (header + body +
//  sticky CTA) over it via the canonical `.appEnter` curve.
//

import SwiftUI
import SwiftData

enum OnboardingPreferencesKeys {
    static let dayCount = "onboarding.dayCount"
    static let dayNames = "onboarding.dayNames"
    static let startOption = "onboarding.startOption"
    static let customStartDate = "onboarding.customStartDate"
}

enum OnboardingPreferences {
    static func save(from viewModel: OnboardingViewModel, defaults: UserDefaults = .standard) {
        defaults.set(viewModel.dayCount, forKey: OnboardingPreferencesKeys.dayCount)
        defaults.set(viewModel.dayNames, forKey: OnboardingPreferencesKeys.dayNames)
        defaults.set(rawStartOption(from: viewModel.startOption), forKey: OnboardingPreferencesKeys.startOption)
        defaults.set(viewModel.customDate.timeIntervalSince1970, forKey: OnboardingPreferencesKeys.customStartDate)
    }

    static func load(into viewModel: OnboardingViewModel, defaults: UserDefaults = .standard) {
        let storedDayCount = defaults.integer(forKey: OnboardingPreferencesKeys.dayCount)
        if storedDayCount > 0 {
            viewModel.updateDayCount(storedDayCount)
        }

        if let names = defaults.stringArray(forKey: OnboardingPreferencesKeys.dayNames), !names.isEmpty {
            viewModel.updateDayCount(max(2, min(6, names.count)))
            for index in viewModel.dayNames.indices {
                if index < names.count {
                    viewModel.dayNames[index] = names[index]
                }
            }
        }

        if let rawOption = defaults.string(forKey: OnboardingPreferencesKeys.startOption) {
            viewModel.startOption = startOption(from: rawOption)
        }

        if defaults.object(forKey: OnboardingPreferencesKeys.customStartDate) != nil {
            let timestamp = defaults.double(forKey: OnboardingPreferencesKeys.customStartDate)
            viewModel.customDate = Date(timeIntervalSince1970: timestamp)
        }
    }

    private static func rawStartOption(from option: OnboardingViewModel.StartOption) -> String {
        switch option {
        case .today:
            return "today"
        case .nextMonday:
            return "nextMonday"
        case .custom:
            return "custom"
        }
    }

    private static func startOption(from rawValue: String) -> OnboardingViewModel.StartOption {
        switch rawValue {
        case "nextMonday":
            return .nextMonday
        case "custom":
            return .custom
        default:
            return .today
        }
    }
}

// MARK: - Step

enum OnboardingStep: Hashable {
    case splash
    case unitPicker
    case importMethod
    case programImport
    case splitBuilder
    case exercises
}

// MARK: - Root View

struct OnboardingView: View {
    /// When true, this onboarding was triggered from Settings → "Start onboarding again".
    /// The flow protects existing data by requiring explicit confirmation before replacing.
    let isRestart: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @AppStorage("unitSystem") private var storedUnitSystem: String = "kg"
    @AppStorage("showOnboardingRestart") private var showOnboardingRestart = false

    @State private var vm: OnboardingViewModel = {
        let vm = OnboardingViewModel()
        vm.seedSampleData()
        return vm
    }()
    @State private var step: OnboardingStep = .exercises
    @State private var history: [OnboardingStep] = []
    @State private var direction: OnboardingSlideDirection = .none
    @State private var commitError: Bool = false
    @State private var showReplaceConfirmation: Bool = false
    @State private var didLoadPreferences = false
    @State private var isCommitting: Bool = false

    init(isRestart: Bool = false) {
        self.isRestart = isRestart
    }

    var body: some View {
        OnboardingFlow(step: step, direction: direction) { current in
            stepView(current)
        }
        .tint(AppColor.accent)
        .environment(vm)
        .alert("Save failed", isPresented: $commitError) {
            Button(AppCopy.Nav.tryAgain, role: .cancel) { }
        } message: {
            Text("Try again in a moment.")
        }
        .confirmationDialog(
            "Replace current program?",
            isPresented: $showReplaceConfirmation,
            titleVisibility: .visible
        ) {
            Button("Replace program", role: .destructive) {
                guard !isCommitting else { return }
                performCommit(replacingExisting: true)
            }
            Button(AppCopy.Nav.cancel, role: .cancel) { }
        } message: {
            Text("Replaces your current program. Workout history is kept.")
        }
        .onAppear {
            guard !didLoadPreferences else { return }
            vm.unitSystem = storedUnitSystem
            OnboardingPreferences.load(into: vm)
            didLoadPreferences = true
        }
    }

    // MARK: - Step → View

    @ViewBuilder
    private func stepView(_ step: OnboardingStep) -> some View {
        switch step {
        case .splash:
            OnboardingSplashView(
                showsDismiss: isRestart,
                onDismiss: dismissOnboarding
            ) {
                push(.unitPicker)
            }

        case .unitPicker:
            OnboardingUnitPickerView(
                progressStep: 1,
                progressTotal: totalRequiredSteps,
                onSelect: { unit in
                    vm.unitSystem = unit
                    push(.importMethod)
                },
                onBack: pop
            )

        case .importMethod:
            OnboardingImportMethodView(
                progressStep: 2,
                progressTotal: totalRequiredSteps,
                onSelect: { method in
                    vm.importMethod = method
                    switch method {
                    case .manual:
                        push(.splitBuilder)
                    case .photo, .paste:
                        push(.programImport)
                    }
                },
                onBack: pop
            )

        case .programImport:
            OnboardingProgramImportView(
                progressStep: 3,
                progressTotal: totalRequiredSteps,
                onContinue: { push(.exercises) },
                onBack: pop
            )

        case .splitBuilder:
            OnboardingSplitBuilderView(
                progressStep: 3,
                progressTotal: totalRequiredSteps,
                onContinue: { push(.exercises) },
                onBack: pop
            )

        case .exercises:
            OnboardingExercisesView(
                progressStep: 4,
                progressTotal: totalRequiredSteps,
                isCommitting: isCommitting,
                onContinue: commitProgram,
                onBack: pop
            )
        }
    }

    private var totalRequiredSteps: Int { 4 }

    // MARK: - Step navigation

    private func push(_ next: OnboardingStep) {
        history.append(step)
        direction = .forward
        step = next
    }

    private func pop() {
        // From the splash, "Back" dismisses the whole onboarding (only
        // reachable on restart from Settings — first-run users see no Back).
        guard let previous = history.popLast() else {
            dismissOnboarding()
            return
        }
        direction = .back
        step = previous
    }

    // MARK: - Commit

    private func commitProgram() {
        guard !isCommitting else { return }
        if isRestart {
            // Check for existing programs — require explicit confirmation to replace
            let descriptor = FetchDescriptor<Split>()
            let existingSplits = (try? modelContext.fetch(descriptor)) ?? []
            if !existingSplits.isEmpty {
                showReplaceConfirmation = true
                return
            }
        }
        performCommit(replacingExisting: false)
    }

    private func performCommit(replacingExisting: Bool) {
        isCommitting = true
        do {
            if replacingExisting {
                try deleteExistingProgramData()
            }
            try vm.commit(modelContext: modelContext)
            storedUnitSystem = vm.unitSystem
            OnboardingPreferences.save(from: vm)
            finishOnboarding()
        } catch {
            isCommitting = false
            commitError = true
        }
    }

    private func deleteExistingProgramData() throws {
        let splits = try modelContext.fetch(FetchDescriptor<Split>())
        let templates = try modelContext.fetch(FetchDescriptor<DayTemplate>())

        for item in templates { modelContext.delete(item) }
        for item in splits { modelContext.delete(item) }
    }

    private func finishOnboarding() {
        showOnboardingRestart = false
        dismiss()
    }

    private func dismissOnboarding() {
        showOnboardingRestart = false
        dismiss()
    }
}

// MARK: - Flow container

/// Direction of the most recent step swap. Drives the asymmetric slide so a
/// forward push enters from the trailing edge and a back pop enters from the
/// leading edge — matching the platform mental model the user already has
/// from native push/pop.
enum OnboardingSlideDirection {
    /// First mount; no transition fires.
    case none
    /// `push` — new step enters from trailing, old leaves to leading.
    case forward
    /// `pop` — new step enters from leading, old leaves to trailing.
    case back
}

/// Owns the single Milk page surface and animates step swaps in place.
///
/// Why not `NavigationStack`: a NavigationStack push slides both source and
/// destination as opaque view-controller rects, which makes the shared Milk
/// page appear to translate between steps even though it never actually
/// changes. `OnboardingFlow` paints the page once at the root and slides only
/// the step content layer — header, body, sticky CTA — over a still surface.
///
/// Reduce Motion: the slide collapses to a pure cross-fade. Per AppMotion
/// doctrine, no horizontal translation when the user has the system
/// preference on.
struct OnboardingFlow<StepContent: View>: View {
    let step: OnboardingStep
    let direction: OnboardingSlideDirection
    @ViewBuilder let stepContent: (OnboardingStep) -> StepContent

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            stepContent(step)
                .id(step)
                .transition(stepTransition)
        }
        .animation(reduceMotion ? .appReveal : .appEnter, value: step)
        // Hide any ambient nav bar (e.g. when this whole flow is pushed onto
        // TemplatesView's `NavigationStack` via "Start onboarding again").
        .toolbar(.hidden, for: .navigationBar)
    }

    private var stepTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        switch direction {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .back:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        case .none:
            return .opacity
        }
    }
}
