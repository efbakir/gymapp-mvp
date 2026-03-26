//
//  ContentView.swift
//  Unit
//
//  Root: Tab navigation (Today, Program, Calendar).
//

import SwiftData
import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall = false
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    @State private var selectedTab: RootTab = .today
    @State private var store = StoreManager()

    private var hasActiveSession: Bool {
        sessions.contains { !$0.isCompleted }
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !hasSeenPaywall && !store.isPurchased {
                PaywallView {
                    hasSeenPaywall = true
                }
                .environment(store)
            } else {
                mainTabView
            }
        }
        .onAppear {
            configureNavigationBarAppearance()
            configureSegmentedControlAppearance()
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
        .tint(AppColor.accent)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !hasActiveSession {
                VStack(spacing: 0) {
                    ScrollEdgeFadeView(
                        edge: .topOfFooter,
                        surfaceColor: AppColor.background
                    )

                    UnitTabBar(
                        items: RootTab.allCases.map {
                            UnitTabBar.Item(id: $0.rawValue, title: $0.title, icon: $0.icon)
                        },
                        selectedID: selectedTab.rawValue
                    ) { id in
                        guard let tab = RootTab(rawValue: id) else { return }
                        selectedTab = tab
                    }
                }
            }
        }
        .environment(\.appTabSelection, AppTabSelection { tab in
            selectedTab = tab
        })
    }

    private func configureNavigationBarAppearance() {
        let titleColor = UIColor(AppColor.textPrimary)
        let backgroundColor = UIColor(AppColor.barBackground)
        let borderColor = UIColor(AppColor.border)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = borderColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]

        let navBar = UINavigationBar.appearance()
        navBar.tintColor = titleColor
        navBar.standardAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
    }

    private func configureSegmentedControlAppearance() {
        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.backgroundColor = UIColor(AppColor.controlBackground)
        segmentedControl.selectedSegmentTintColor = UIColor(AppColor.accent)
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.textSecondary)],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.accentForeground)],
            for: .selected
        )
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
            return "Program"
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

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.makePreviewContainer())

}
