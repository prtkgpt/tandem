import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }

            UsView()
                .tabItem {
                    Label("Us", systemImage: "heart.fill")
                }

            DateNightView()
                .tabItem {
                    Label("Date Night", systemImage: "sparkles")
                }

            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.primary)
    }
}
