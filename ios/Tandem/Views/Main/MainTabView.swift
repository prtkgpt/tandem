import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0

    // Tab configuration
    private struct TabItem {
        let title: String
        let iconDefault: String
        let iconSelected: String
        let color: Color
        let tag: Int
    }

    private let tabs: [TabItem] = [
        TabItem(
            title: "Today",
            iconDefault: "sun.max",
            iconSelected: "sun.max.fill",
            color: TandemColors.primary,
            tag: 0
        ),
        TabItem(
            title: "Us",
            iconDefault: "heart",
            iconSelected: "heart.fill",
            color: TandemColors.appreciationColor,
            tag: 1
        ),
        TabItem(
            title: "Date Night",
            iconDefault: "sparkles",
            iconSelected: "sparkles",
            color: TandemColors.dateNightColor,
            tag: 2
        ),
        TabItem(
            title: "Goals",
            iconDefault: "target",
            iconSelected: "target",
            color: TandemColors.goalColor,
            tag: 3
        ),
        TabItem(
            title: "More",
            iconDefault: "line.3.horizontal",
            iconSelected: "line.3.horizontal",
            color: TandemColors.textSecondary,
            tag: 4
        ),
    ]

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    tabLabel(for: tabs[0])
                }
                .tag(0)

            UsView()
                .tabItem {
                    tabLabel(for: tabs[1])
                }
                .tag(1)

            DateNightView()
                .tabItem {
                    tabLabel(for: tabs[2])
                }
                .tag(2)

            GoalsView()
                .tabItem {
                    tabLabel(for: tabs[3])
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    tabLabel(for: tabs[4])
                }
                .tag(4)
        }
        .tint(activeTabColor)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    // MARK: - Tab Label

    @ViewBuilder
    private func tabLabel(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab.tag
        Label {
            Text(tab.title)
        } icon: {
            Image(systemName: isSelected ? tab.iconSelected : tab.iconDefault)
        }
    }

    // MARK: - Active Tab Color

    private var activeTabColor: Color {
        guard selectedTab < tabs.count else { return TandemColors.primary }
        return tabs[selectedTab].color
    }

    // MARK: - Tab Bar Appearance

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Warm off-white background matching the app theme
        appearance.backgroundColor = UIColor(TandemColors.cardBackground)

        // Subtle top separator line
        appearance.shadowColor = UIColor(TandemColors.divider)

        // Normal (unselected) item colors
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(TandemColors.textSecondary.opacity(0.6)),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(
            TandemColors.textSecondary.opacity(0.5)
        )

        // Selected item uses the tint color automatically, but we set font weight
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
