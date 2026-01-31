import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(0)

            UsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Us")
                }
                .tag(1)

            DateNightView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Date Night")
                }
                .tag(2)

            GoalsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Goals")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("More")
                }
                .tag(4)
        }
        .tint(TandemColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
