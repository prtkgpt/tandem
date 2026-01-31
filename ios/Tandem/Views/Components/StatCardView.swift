import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: TandemSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(TandemColors.primary)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(TandemColors.textPrimary)

            Text(title)
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(TandemSpacing.md)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        StatCardView(
            title: "Together",
            value: "42",
            icon: "calendar.badge.clock"
        )

        StatCardView(
            title: "Appreciations",
            value: "18",
            icon: "heart.fill"
        )

        StatCardView(
            title: "Date Nights",
            value: "6",
            icon: "sparkles"
        )
    }
    .padding()
}
