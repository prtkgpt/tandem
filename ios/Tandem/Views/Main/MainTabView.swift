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
            title: "Board",
            iconDefault: "list.clipboard",
            iconSelected: "list.clipboard.fill",
            color: TandemColors.boardColor,
            tag: 1
        ),
        TabItem(
            title: "Moments",
            iconDefault: "calendar",
            iconSelected: "calendar",
            color: TandemColors.calendarColor,
            tag: 2
        ),
        TabItem(
            title: "Us",
            iconDefault: "heart",
            iconSelected: "heart.fill",
            color: TandemColors.appreciationColor,
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

            BoardView()
                .tabItem {
                    tabLabel(for: tabs[1])
                }
                .tag(1)

            CalendarView()
                .tabItem {
                    tabLabel(for: tabs[2])
                }
                .tag(2)

            UsView()
                .tabItem {
                    tabLabel(for: tabs[3])
                }
                .tag(3)

            MoreView()
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

        appearance.backgroundColor = UIColor(TandemColors.cardBackground)
        appearance.shadowColor = UIColor(TandemColors.divider)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(TandemColors.textSecondary.opacity(0.6)),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(
            TandemColors.textSecondary.opacity(0.5)
        )

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - More View (Date Night, Goals, Settings)

struct MoreView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TandemSpacing.md) {
                    // Date Night
                    NavigationLink {
                        DateNightView()
                            .environmentObject(appViewModel)
                    } label: {
                        moreRow(
                            icon: "sparkles",
                            title: "Date Night",
                            subtitle: "Plan something special",
                            color: TandemColors.dateNightColor
                        )
                    }

                    // Goals
                    NavigationLink {
                        GoalsView()
                    } label: {
                        moreRow(
                            icon: "target",
                            title: "Savings Goals",
                            subtitle: "Save together toward dreams",
                            color: TandemColors.goalColor
                        )
                    }

                    Divider()
                        .padding(.horizontal, TandemSpacing.md)

                    // Settings
                    NavigationLink {
                        SettingsView()
                            .environmentObject(appViewModel)
                    } label: {
                        moreRow(
                            icon: "gearshape.fill",
                            title: "Settings",
                            subtitle: "Account, notifications, preferences",
                            color: TandemColors.textSecondary
                        )
                    }
                }
                .padding(.vertical, TandemSpacing.md)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .navigationTitle("More")
        }
    }

    private func moreRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: TandemSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                Text(title)
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Text(subtitle)
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary.opacity(0.4))
        }
        .padding(TandemSpacing.md)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(
            color: TandemShadow.soft.color,
            radius: TandemShadow.soft.radius,
            x: TandemShadow.soft.x,
            y: TandemShadow.soft.y
        )
        .padding(.horizontal, TandemSpacing.md)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
