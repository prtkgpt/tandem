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
                VStack(spacing: TandemSpacing.lg) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.timeColor))
                            .padding(.top, 60)
                    } else {
                        usHeader
                        weeklyProgressCard
                        quickStatsSection
                        recentAppreciationsSection
                        stateOfUsButton
                    }
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
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
                    VStack(spacing: TandemSpacing.md) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundColor(TandemColors.textSecondary.opacity(0.4))
                        Text("No weekly summary yet")
                            .font(TandemFonts.headline)
                            .foregroundColor(TandemColors.textPrimary)
                        Text("Check back after your first Sunday together!")
                            .font(TandemFonts.body)
                            .foregroundColor(TandemColors.textSecondary)
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Header

    private var usHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    TandemColors.timeColor.opacity(0.12),
                    TandemColors.secondary.opacity(0.06),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 130)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                Text("Your Relationship")
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                if let partner = appViewModel.partnerName {
                    Text("You & \(partner)")
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.timeColor)
                }
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Weekly Progress

    private var weeklyProgressCard: some View {
        VStack(spacing: TandemSpacing.md) {
            HStack {
                Image(systemName: "clock.fill")
                    .iconBadge(color: TandemColors.timeColor)
                Text("Our Time This Week")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Spacer()
            }

            ProgressRingView(
                progress: weeklyProgress,
                lineWidth: 14,
                size: 140,
                label: hoursLabel
            )
        }
        .sectionCard(color: TandemColors.timeColor)
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        Group {
            if let stats = stats {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: TandemSpacing.sm) {
                    StatCardView(
                        title: "Days Together",
                        value: "\(stats.daysOnTandem)",
                        icon: "heart.fill",
                        accentColor: TandemColors.primary
                    )
                    StatCardView(
                        title: "Appreciations",
                        value: "\(stats.totalAppreciations)",
                        icon: "sparkle",
                        accentColor: TandemColors.appreciationColor
                    )
                    StatCardView(
                        title: "Date Nights",
                        value: "\(stats.totalDateNights)",
                        icon: "sparkles",
                        accentColor: TandemColors.dateNightColor
                    )
                }
                .padding(.horizontal, TandemSpacing.md)
            }
        }
    }

    // MARK: - Appreciations

    private var recentAppreciationsSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "heart.text.square.fill")
                    .iconBadge(color: TandemColors.appreciationColor)
                Text("This Week's Appreciations")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, TandemSpacing.md)

            if appreciations.isEmpty {
                VStack(spacing: TandemSpacing.sm) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 32))
                        .foregroundColor(TandemColors.appreciationColor.opacity(0.4))
                    Text("No appreciations this week yet")
                        .font(TandemFonts.callout)
                        .foregroundColor(TandemColors.textSecondary)
                    Text("Notice something about your partner today!")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(TandemSpacing.lg)
                .background(TandemColors.appreciationColor.opacity(0.05))
                .cornerRadius(TandemCornerRadius.card)
                .padding(.horizontal, TandemSpacing.md)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TandemSpacing.sm) {
                        ForEach(appreciations.prefix(10)) { appreciation in
                            AppreciationCardView(
                                appreciation: appreciation,
                                isFromMe: appreciation.fromUserId == appViewModel.currentUser?.id
                            )
                            .frame(width: 260)
                        }
                    }
                    .padding(.horizontal, TandemSpacing.md)
                }
            }
        }
    }

    // MARK: - State of Us

    private var stateOfUsButton: some View {
        Button {
            showSummarySheet = true
        } label: {
            HStack(spacing: TandemSpacing.md) {
                ZStack {
                    Circle()
                        .fill(TandemColors.secondary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 22))
                        .foregroundColor(TandemColors.secondary)
                }

                VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                    Text("State of Us")
                        .font(TandemFonts.headline)
                        .foregroundColor(TandemColors.textPrimary)
                    Text("View your weekly relationship summary")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary.opacity(0.6))
            }
        }
        .tandemCard()
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Data Loading

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
