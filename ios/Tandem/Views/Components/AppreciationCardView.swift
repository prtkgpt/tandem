import SwiftUI

struct AppreciationCardView: View {
    let appreciation: Appreciation
    let isFromMe: Bool

    @State private var appeared: Bool = false

    // MARK: - Computed

    private var senderLabel: String {
        isFromMe ? "You" : appreciation.fromUserName
    }

    private var relativeTime: String {
        if let date = appreciation.createdAt.toDate() {
            return date.relativeDescription
        }
        return ""
    }

    private var cardBackground: Color {
        isFromMe
            ? TandemColors.primary.opacity(0.06)
            : TandemColors.cardBackground
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: TandemSpacing.md) {
            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 18))
                .foregroundColor(TandemColors.primary.opacity(0.6))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                // Sender and time
                HStack {
                    Text(senderLabel)
                        .font(TandemFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            isFromMe ? TandemColors.primary : TandemColors.secondary
                        )

                    Spacer()

                    if !relativeTime.isEmpty {
                        Text(relativeTime)
                            .font(TandemFonts.caption)
                            .foregroundColor(TandemColors.textSecondary)
                    }
                }

                // Message
                Text(appreciation.message)
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(TandemSpacing.md)
        .background(cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .offset(x: appeared ? 0 : (isFromMe ? 30 : -30))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        AppreciationCardView(
            appreciation: Appreciation(
                id: "1",
                fromUserId: "user1",
                fromUserName: "Jordan",
                message: "Thanks for making coffee this morning -- it really brightened my day!",
                createdAt: "2026-01-31T08:00:00Z"
            ),
            isFromMe: true
        )

        AppreciationCardView(
            appreciation: Appreciation(
                id: "2",
                fromUserId: "user2",
                fromUserName: "Alex",
                message: "I loved how you listened so patiently last night. You always know how to make me feel heard.",
                createdAt: "2026-01-30T22:00:00Z"
            ),
            isFromMe: false
        )
    }
    .padding()
}
