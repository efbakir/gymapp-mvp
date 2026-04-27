//
//  ContentView.swift
//  Unit
//
//  Root: Tab navigation (Today, Program).
//
import SwiftData
import SwiftUI
import UIKit

private extension UIFont {
    func rounded() -> UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

struct ContentView: View {
    @AppStorage(wrappedValue: false, "hasSeenPaywall") private var hasSeenPaywall
    @AppStorage(wrappedValue: false, "showOnboardingRestart") private var showOnboardingRestart

    @Query(sort: \Split.name) private var splits: [Split]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @State private var selectedTab: RootTab = .today
    @State private var store: StoreManager

    /// Uses `UserDefaults.standard` in the app; pass an isolated suite in `#Preview` so canvas state does not touch real onboarding flags.
    init(userDefaults: UserDefaults = .standard) {
        _hasSeenPaywall = AppStorage(wrappedValue: false, "hasSeenPaywall", store: userDefaults)
        _showOnboardingRestart = AppStorage(wrappedValue: false, "showOnboardingRestart", store: userDefaults)
        _splits = Query(sort: \Split.name)
        _sessions = Query(sort: \WorkoutSession.date, order: .reverse)
        _store = State(initialValue: StoreManager())
    }

    private var hasActiveSession: Bool {
        sessions.contains { !$0.isCompleted }
    }

    /// True new user: no program and no workout sessions at all.
    private var needsOnboarding: Bool {
        splits.isEmpty && sessions.isEmpty
    }

    var body: some View {
        Group {
            if needsOnboarding {
                OnboardingView()
            } else if showOnboardingRestart {
                OnboardingView(isRestart: true)
            } else {
                // Paywall deferred — ship v1 free to validate retention
                // without price as a confound. Monetize after proving habit.
                mainTabView
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .onAppear {
            configureNavigationBarAppearance()
            configureSegmentedControlAppearance()
            configureTabBarAppearance()
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label(RootTab.today.title, systemImage: RootTab.today.systemImage)
                }
                .tag(RootTab.today)

            TemplatesView()
                .tabItem {
                    Label(RootTab.program.title, systemImage: RootTab.program.systemImage)
                }
                .tag(RootTab.program)
        }
        .tint(AppColor.systemTint)
        .toolbar(hasActiveSession ? .hidden : .visible, for: .tabBar)
        .environment(\.appTabSelection, AppTabSelection { tab in
            selectedTab = tab
        })
    }

    private func configureNavigationBarAppearance() {
        let titleColor = UIColor(AppColor.textPrimary)
        let backgroundColor = UIColor(AppColor.barBackground)
        let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold).rounded()
        let largeTitleFont = UIFont.systemFont(ofSize: 34, weight: .bold).rounded()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: titleColor, .font: titleFont]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor, .font: largeTitleFont]

        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: titleColor, .font: titleFont]
        scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor, .font: largeTitleFont]

        let navBar = UINavigationBar.appearance()
        navBar.tintColor = titleColor
        navBar.standardAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.scrollEdgeAppearance = scrollEdgeAppearance
    }

    private func configureSegmentedControlAppearance() {
        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.backgroundColor = UIColor(AppColor.controlBackground)
        segmentedControl.selectedSegmentTintColor = UIColor.white
        let normalFont = UIFont.systemFont(ofSize: 14, weight: .medium).rounded()
        let selectedFont = UIFont.systemFont(ofSize: 14, weight: .semibold).rounded()
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.textSecondary), .font: normalFont],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.textPrimary), .font: selectedFont],
            for: .selected
        )
    }

    private func configureTabBarAppearance() {
        let tabFont = UIFont.systemFont(ofSize: 10, weight: .medium).rounded()
        let attributes: [NSAttributedString.Key: Any] = [.font: tabFont]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
    }
}

struct AppTabSelection {
    let select: (RootTab) -> Void

    func callAsFunction(_ tab: RootTab) {
        select(tab)
    }
}

private struct AppTabSelectionKey: EnvironmentKey {
    static let defaultValue = AppTabSelection { _ in }
}

extension EnvironmentValues {
    var appTabSelection: AppTabSelection {
        get { self[AppTabSelectionKey.self] }
        set { self[AppTabSelectionKey.self] = newValue }
    }
}

enum RootTab: String, CaseIterable, Hashable {
    case today
    case program

    var title: String {
        switch self {
        case .today:
            return "Today"
        case .program:
            return "Programs"
        }
    }

    var systemImage: String {
        switch self {
        case .today:
            return AppIcon.todayTab.systemName
        case .program:
            return AppIcon.program.systemName
        }
    }

    var icon: AppIcon {
        switch self {
        case .today:
            return .todayTab
        case .program:
            return .program
        }
    }
}

private enum ContentViewPreviewDefaults {
    static var userDefaults: UserDefaults {
        let suite = UserDefaults(suiteName: "unit.preview.ContentView")!
        suite.set(true, forKey: "hasSeenPaywall")
        suite.set(false, forKey: "showOnboardingRestart")
        return suite
    }
}

#Preview {
    ContentView(userDefaults: ContentViewPreviewDefaults.userDefaults)
        .modelContainer(PreviewSampleData.makePreviewContainer())
}
