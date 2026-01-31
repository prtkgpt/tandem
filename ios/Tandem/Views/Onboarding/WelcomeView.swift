import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void

    @State private var heartScale: CGFloat = 0.5
    @State private var heartOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var featuresOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Heart Icon
            heartIcon
                .padding(.bottom, TandemSpacing.lg)

            // MARK: - Title
            titleSection
                .padding(.bottom, TandemSpacing.xl)

            // MARK: - Feature Highlights
            featureHighlights
                .padding(.horizontal, TandemSpacing.xl)
                .padding(.bottom, TandemSpacing.xl)

            Spacer()

            // MARK: - Get Started Button
            getStartedButton
                .padding(.horizontal, TandemSpacing.xl)
                .padding(.bottom, TandemSpacing.xl)
        }
        .onAppear {
            animateEntrance()
        }
    }

    // MARK: - Heart Icon

    private var heartIcon: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(TandemColors.primary.opacity(0.15))
                .frame(width: 140, height: 140)
                .scaleEffect(heartScale * 1.2)

            // Inner circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: TandemColors.primary.opacity(0.4), radius: 20, x: 0, y: 8)

            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundColor(.white)
        }
        .scaleEffect(heartScale)
        .opacity(heartOpacity)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            Text("Tandem")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Stay Connected as a Couple")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textSecondary)
        }
        .offset(y: titleOffset)
        .opacity(titleOpacity)
    }

    // MARK: - Feature Highlights

    private var featureHighlights: some View {
        VStack(spacing: TandemSpacing.md) {
            FeatureRow(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Table Topics",
                description: "Daily questions to spark meaningful conversations",
                iconColor: TandemColors.primary
            )

            FeatureRow(
                icon: "heart.text.square.fill",
                title: "Appreciations",
                description: "Share what you love about each other",
                iconColor: TandemColors.secondary
            )

            FeatureRow(
                icon: "calendar.badge.clock",
                title: "Date Planning",
                description: "Plan and track quality time together",
                iconColor: TandemColors.accent
            )
        }
        .opacity(featuresOpacity)
    }

    // MARK: - Get Started Button

    private var getStartedButton: some View {
        Button(action: onGetStarted) {
            HStack(spacing: TandemSpacing.sm) {
                Text("Get Started")

                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .tandemButton()
        }
        .opacity(buttonOpacity)
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            heartScale = 1.0
            heartOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            featuresOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: TandemSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)

                Text(description)
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(TandemSpacing.sm)
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
}
