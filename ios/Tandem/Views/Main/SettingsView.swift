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
                    HStack(spacing: TandemSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [TandemColors.primary, TandemColors.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            Text(String((appViewModel.currentUser?.name ?? "?").prefix(1)).uppercased())
                                .font(TandemFonts.title)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                            Text(appViewModel.currentUser?.name ?? "User")
                                .font(TandemFonts.headline)
                                .foregroundColor(TandemColors.textPrimary)
                            Text(appViewModel.currentUser?.email ?? "")
                                .font(TandemFonts.caption)
                                .foregroundColor(TandemColors.textSecondary)
                        }
                    }
                    .padding(.vertical, TandemSpacing.xs)
                }

                // Partner
                Section("Partner") {
                    if appViewModel.isPaired, let partner = appViewModel.partnerName {
                        HStack(spacing: TandemSpacing.sm) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(TandemColors.primary)
                            Text("Connected with \(partner)")
                                .font(TandemFonts.body)
                                .foregroundColor(TandemColors.textPrimary)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(TandemColors.secondary)
                        }
                    } else {
                        HStack(spacing: TandemSpacing.sm) {
                            Image(systemName: "link")
                                .foregroundColor(TandemColors.textSecondary)
                            Text("Not yet paired")
                                .font(TandemFonts.body)
                                .foregroundColor(TandemColors.textSecondary)
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
                    .font(TandemFonts.body)
                }

                // Subscription
                Section("Subscription") {
                    HStack(spacing: TandemSpacing.sm) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(TandemColors.accent)
                        VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                            Text(appViewModel.couple?.subscriptionStatus == "active" ? "Tandem Pro" : "Free Trial")
                                .font(TandemFonts.callout)
                                .foregroundColor(TandemColors.textPrimary)
                            Text("$4.99/month after trial")
                                .font(TandemFonts.caption)
                                .foregroundColor(TandemColors.textSecondary)
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                            .font(TandemFonts.body)
                            .foregroundColor(TandemColors.textPrimary)
                        Spacer()
                        Text("0.1.0")
                            .font(TandemFonts.caption)
                            .foregroundColor(TandemColors.textSecondary)
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
                                .font(TandemFonts.callout)
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
