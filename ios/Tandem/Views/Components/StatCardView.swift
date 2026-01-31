import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    var accentColor: Color = TandemColors.primary

    var body: some View {
        VStack(spacing: TandemSpacing.sm) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(TandemColors.textPrimary)

            Text(title)
                .font(TandemFonts.micro)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TandemSpacing.md)
        .padding(.horizontal, TandemSpacing.sm)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(
            color: TandemShadow.card.color,
            radius: TandemShadow.card.radius,
            x: TandemShadow.card.x,
            y: TandemShadow.card.y
        )
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        StatCardView(
            title: "Together",
            value: "42",
            icon: "heart.fill",
            accentColor: TandemColors.primary
        )

        StatCardView(
            title: "Appreciations",
            value: "18",
            icon: "sparkle",
            accentColor: TandemColors.appreciationColor
        )

        StatCardView(
            title: "Date Nights",
            value: "6",
            icon: "sparkles",
            accentColor: TandemColors.dateNightColor
        )
    }
    .padding()
}
