import SwiftUI

struct GoalCardView: View {
    let goal: SavingsGoal
    let onContribute: () -> Void

    @State private var animatedProgress: CGFloat = 0

    // MARK: - Computed

    private var progress: CGFloat {
        guard goal.targetAmount > 0 else { return 0 }
        return min(CGFloat(goal.currentAmount / goal.targetAmount), 1.0)
    }

    private var percentText: String {
        "\(Int(progress * 100))%"
    }

    private var currentFormatted: String {
        formatCurrency(goal.currentAmount)
    }

    private var targetFormatted: String {
        formatCurrency(goal.targetAmount)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            // Header row: emoji + name + percentage badge
            HStack {
                Text(goal.emoji)
                    .font(.system(size: 28))

                Text(goal.name)
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)

                Spacer()

                // Percentage badge
                Text(percentText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, TandemSpacing.sm)
                    .padding(.vertical, TandemSpacing.xs)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [TandemColors.primary, TandemColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }

            // Progress bar
            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.gray.opacity(0.12))
                            .frame(height: 10)

                        // Fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [TandemColors.primary, TandemColors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * animatedProgress,
                                height: 10
                            )
                    }
                }
                .frame(height: 10)

                // Amount labels
                HStack {
                    Text(currentFormatted)
                        .font(TandemFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(TandemColors.textPrimary)

                    Spacer()

                    Text(targetFormatted)
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }

            // Add button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onContribute()
            }) {
                HStack(spacing: TandemSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Add")
                        .font(TandemFonts.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(TandemColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TandemSpacing.sm)
                .background(TandemColors.primary.opacity(0.08))
                .cornerRadius(TandemCornerRadius.button)
            }
        }
        .padding(TandemSpacing.md)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                animatedProgress = progress
            }
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        GoalCardView(
            goal: SavingsGoal(
                id: "1",
                name: "Anniversary Trip",
                targetAmount: 3000,
                currentAmount: 1850,
                emoji: "✈️",
                contributions: []
            ),
            onContribute: {}
        )

        GoalCardView(
            goal: SavingsGoal(
                id: "2",
                name: "New Couch",
                targetAmount: 1200,
                currentAmount: 300,
                emoji: "🛋️",
                contributions: []
            ),
            onContribute: {}
        )
    }
    .padding()
}
