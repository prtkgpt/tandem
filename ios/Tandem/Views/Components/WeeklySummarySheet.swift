import SwiftUI

struct WeeklySummarySheet: View {
    let summary: WeeklySummary
    let weeklyGoalHours: Int
    let partnerName: String
    let onDismiss: () -> Void

    // MARK: - Computed

    private var totalHours: Double {
        Double(summary.totalTimeMinutes) / 60.0
    }

    private var goalProgress: Double {
        guard weeklyGoalHours > 0 else { return 0 }
        return min(totalHours / Double(weeklyGoalHours), 1.0)
    }

    private var timeLabel: String {
        let hours = totalHours
        if hours >= 1 {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            if m > 0 {
                return "\(h)h \(m)m / \(weeklyGoalHours)h"
            }
            return "\(h)h / \(weeklyGoalHours)h"
        }
        return "\(summary.totalTimeMinutes)m / \(weeklyGoalHours)h"
    }

    private var weekDateRange: String {
        guard let startDate = summary.weekStartDate.toDate() else {
            return summary.weekStartDate
        }
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: TandemSpacing.xl) {
                    headerSection
                    progressSection
                    winsSection
                    nudgeSection
                    appreciationsSection
                    footerSection
                }
                .padding(TandemSpacing.lg)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .font(TandemFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(TandemColors.primary)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            Text("Your State of Us")
                .font(TandemFonts.largeTitle)
                .foregroundColor(TandemColors.textPrimary)

            Text(weekDateRange)
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, TandemSpacing.md)
    }

    // MARK: - Progress Ring

    private var progressSection: some View {
        VStack(spacing: TandemSpacing.md) {
            ProgressRingView(
                progress: goalProgress,
                lineWidth: 14,
                size: 160,
                label: timeLabel
            )

            Text(goalProgress >= 1.0 ? "Goal reached!" : "Time together this week")
                .font(TandemFonts.body)
                .foregroundColor(
                    goalProgress >= 1.0 ? TandemColors.secondary : TandemColors.textSecondary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TandemSpacing.md)
    }

    // MARK: - Wins

    private var winsSection: some View {
        Group {
            if !summary.wins.isEmpty {
                VStack(alignment: .leading, spacing: TandemSpacing.md) {
                    Text("This Week's Wins")
                        .font(TandemFonts.headline)
                        .foregroundColor(TandemColors.textPrimary)

                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        ForEach(Array(summary.wins.enumerated()), id: \.offset) { index, win in
                            HStack(alignment: .top, spacing: TandemSpacing.sm) {
                                Text("\(index + 1).")
                                    .font(TandemFonts.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(TandemColors.primary)
                                    .frame(width: 24, alignment: .leading)

                                Text(win)
                                    .font(TandemFonts.body)
                                    .foregroundColor(TandemColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(TandemSpacing.md)
                .background(TandemColors.cardBackground)
                .cornerRadius(TandemCornerRadius.card)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
            }
        }
    }

    // MARK: - Nudge

    private var nudgeSection: some View {
        Group {
            if let nudge = summary.nudge, !nudge.isEmpty {
                VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                    HStack(spacing: TandemSpacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "F0A500"))

                        Text("Gentle Nudge")
                            .font(TandemFonts.headline)
                            .foregroundColor(TandemColors.textPrimary)
                    }

                    Text(nudge)
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(TandemSpacing.md)
                .background(Color(hex: "FFF3CD").opacity(0.6))
                .cornerRadius(TandemCornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                        .stroke(Color(hex: "F0A500").opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Appreciations Count

    private var appreciationsSection: some View {
        HStack(spacing: TandemSpacing.md) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(TandemColors.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(summary.totalAppreciations)")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.textPrimary)

                Text("appreciations shared")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
            }

            Spacer()
        }
        .padding(TandemSpacing.md)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            Text("Keep it up!")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.primary)

            Text("Every moment together makes your connection stronger, \(partnerName) is lucky to have you.")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TandemSpacing.lg)
    }
}

// MARK: - Preview

#Preview {
    WeeklySummarySheet(
        summary: WeeklySummary(
            id: "ws1",
            weekStartDate: "2026-01-26T00:00:00Z",
            totalTimeMinutes: 320,
            totalAppreciations: 5,
            wins: [
                "You spent 5+ hours of quality time together",
                "You both responded to every Table Topic",
                "3 appreciations sent to each other"
            ],
            nudge: "Try scheduling a dedicated date night this week -- even 30 minutes of focused time can make a big difference.",
            createdAt: "2026-02-01T00:00:00Z"
        ),
        weeklyGoalHours: 7,
        partnerName: "Alex",
        onDismiss: {}
    )
}
