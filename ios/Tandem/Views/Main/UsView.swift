import SwiftUI

struct UsView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var stats: CoupleStats?
    @State private var appreciations: [Appreciation] = []
    @State private var timeLogs: [OurTimeLog] = []
    @State private var weeklySummary: WeeklySummary?
    @State private var showSummarySheet = false
    @State private var isLoading = true

    private var weeklyProgress: Double {
        guard let stats = stats, stats.weeklyGoalHours > 0 else { return 0 }
        let hoursLogged = Double(stats.totalTimeThisWeek) / 60.0
        return min(hoursLogged / Double(stats.weeklyGoalHours), 1.0)
    }

    private var hoursLabel: String {
        guard let stats = stats else { return "0 / 7 hrs" }
        let hours = Double(stats.totalTimeThisWeek) / 60.0
        return String(format: "%.1f / %d hrs", hours, stats.weeklyGoalHours)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 60)
                    } else {
                        // Weekly Progress Ring
                        VStack(spacing: 12) {
                            Text("Our Time This Week")
                                .font(.headline)
                                .foregroundColor(TandemColors.textPrimary)
                            ProgressRingView(
                                progress: weeklyProgress,
                                lineWidth: 14,
                                size: 150,
                                label: hoursLabel
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(TandemCornerRadius.card)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        .padding(.horizontal)

                        // Quick Stats
                        if let stats = stats {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatCardView(
                                    title: "Days Together",
                                    value: "\(stats.daysOnTandem)",
                                    icon: "heart.fill"
                                )
                                StatCardView(
                                    title: "Appreciations",
                                    value: "\(stats.totalAppreciations)",
                                    icon: "sparkle"
                                )
                                StatCardView(
                                    title: "Date Nights",
                                    value: "\(stats.totalDateNights)",
                                    icon: "sparkles"
                                )
                            }
                            .padding(.horizontal)
                        }

                        // Recent Appreciations
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Week's Appreciations")
                                .font(.headline)
                                .foregroundColor(TandemColors.textPrimary)
                                .padding(.horizontal)

                            if appreciations.isEmpty {
                                Text("No appreciations this week yet. Notice something about your partner today!")
                                    .font(.subheadline)
                                    .foregroundColor(TandemColors.textSecondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(TandemCornerRadius.card)
                                    .padding(.horizontal)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(appreciations.prefix(10)) { appreciation in
                                            AppreciationCardView(
                                                appreciation: appreciation,
                                                isFromMe: appreciation.fromUserId == appViewModel.currentUser?.id
                                            )
                                            .frame(width: 260)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // State of Us
                        Button {
                            showSummarySheet = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("View State of Us")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(TandemColors.primary.opacity(0.1))
                            .foregroundColor(TandemColors.primary)
                            .cornerRadius(TandemCornerRadius.button)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(TandemColors.background)
            .navigationTitle("Us")
            .refreshable { await loadData() }
            .task { await loadData() }
            .sheet(isPresented: $showSummarySheet) {
                if let summary = weeklySummary {
                    WeeklySummarySheet(
                        summary: summary,
                        weeklyGoalHours: stats?.weeklyGoalHours ?? 7,
                        partnerName: appViewModel.partnerName ?? "Partner",
                        onDismiss: { showSummarySheet = false }
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.largeTitle)
                            .foregroundColor(TandemColors.textSecondary)
                        Text("No weekly summary yet")
                            .font(.headline)
                        Text("Check back after your first Sunday together!")
                            .font(.subheadline)
                            .foregroundColor(TandemColors.textSecondary)
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
            }
        }
    }

    private func loadData() async {
        do {
            async let statsReq = APIService.shared.getStats()
            async let appreciationsReq = APIService.shared.getAppreciations()
            async let timeReq = APIService.shared.getTimeLogs()
            async let summaryReq = APIService.shared.getWeeklySummary()

            let (s, a, t, ws) = try await (statsReq, appreciationsReq, timeReq, summaryReq)
            stats = s
            appreciations = a.appreciations
            timeLogs = t.timeLogs
            weeklySummary = ws.summary
        } catch {
            print("Failed to load Us data: \(error)")
        }
        isLoading = false
    }
}
