import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var notificationHour = 18
    @State private var notificationMinute = 30
    @State private var weeklyGoal = 7

    private var notificationTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = notificationHour
                components.minute = notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                notificationHour = comps.hour ?? 18
                notificationMinute = comps.minute ?? 30
                NotificationService.shared.scheduleDailyTopicReminder(
                    hour: notificationHour, minute: notificationMinute
                )
            }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                // Profile
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.primary, Theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            Text(String(appViewModel.currentUser?.name.prefix(1) ?? "?").uppercased())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appViewModel.currentUser?.name ?? "User")
                                .font(.headline)
                            Text(appViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Partner
                Section("Partner") {
                    if appViewModel.isPaired, let partner = appViewModel.partnerName {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Theme.primary)
                            Text("Connected with \(partner)")
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(Theme.textSecondary)
                            Text("Not yet paired")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }

                // Notifications
                Section("Notifications") {
                    DatePicker(
                        "Daily Topic Time",
                        selection: notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                }

                // Subscription
                Section("Subscription") {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text(appViewModel.couple?.subscriptionStatus == "active" ? "Tandem Pro" : "Free Trial")
                                .fontWeight(.medium)
                            Text("$4.99/month after trial")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.1.0")
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                // Sign Out
                Section {
                    Button(role: .destructive) {
                        appViewModel.logout()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                notificationHour = appViewModel.currentUser?.notificationHour ?? 18
                notificationMinute = appViewModel.currentUser?.notificationMin ?? 30
            }
        }
    }
}
