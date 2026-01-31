import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onEnterCode: () -> Void
    let onSignIn: () -> Void

    @State private var heartScale: CGFloat = 0.3
    @State private var heartOpacity: Double = 0
    @State private var pulseScale: CGFloat = 0.8
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var featuresOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 40
    @State private var buttonsOpacity: Double = 0
    @State private var signInOpacity: Double = 0
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Hero Icon
            heroIcon
                .padding(.bottom, TandemSpacing.lg)

            // MARK: - Title & Tagline
            titleSection
                .padding(.bottom, TandemSpacing.xl)

            // MARK: - Feature Highlights
            featureHighlights
                .padding(.horizontal, TandemSpacing.xl)

            Spacer()

            // MARK: - Action Buttons
            actionButtons
                .padding(.horizontal, TandemSpacing.xl)
                .padding(.bottom, TandemSpacing.md)

            // MARK: - Sign In Link
            signInLink
                .padding(.bottom, TandemSpacing.xl)
        }
        .background(TandemColors.background.ignoresSafeArea())
        .onAppear {
            animateEntrance()
        }
    }

    // MARK: - Hero Icon

    private var heroIcon: some View {
        ZStack {
            // Animated pulse ring
            Circle()
                .fill(TandemColors.primary.opacity(0.08))
                .frame(width: 160, height: 160)
                .scaleEffect(isPulsing ? 1.15 : 0.95)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            TandemColors.primary.opacity(0.2),
                            TandemColors.primary.opacity(0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 80
                    )
                )
                .frame(width: 150, height: 150)

            // Main gradient circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            TandemColors.primary,
                            TandemColors.accent
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: TandemColors.primary.opacity(0.4), radius: 24, x: 0, y: 10)

            // Heart icon with inner shadow
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .scaleEffect(heartScale)
        .opacity(heartOpacity)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            Text("Tandem")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Your relationship, beautifully in sync")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TandemSpacing.xl)
        }
        .offset(y: titleOffset)
        .opacity(titleOpacity)
    }

    // MARK: - Feature Highlights

    private var featureHighlights: some View {
        VStack(spacing: TandemSpacing.md) {
            FeatureHighlightRow(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Table Topics",
                description: "Daily questions to spark meaningful conversations",
                iconColor: TandemColors.primary
            )

            FeatureHighlightRow(
                icon: "heart.text.square.fill",
                title: "Appreciations",
                description: "Share what you love about each other",
                iconColor: TandemColors.secondary
            )

            FeatureHighlightRow(
                icon: "calendar.badge.clock",
                title: "Date Planning",
                description: "Plan and track quality time together",
                iconColor: TandemColors.accent
            )
        }
        .opacity(featuresOpacity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: TandemSpacing.sm + 2) {
            // Primary: Get Started
            Button(action: onGetStarted) {
                HStack(spacing: TandemSpacing.sm) {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tandemButton()
            }

            // Secondary: I have an invite code
            Button(action: onEnterCode) {
                HStack(spacing: TandemSpacing.sm) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 15))
                    Text("I have an invite code")
                }
                .tandemSecondaryButton()
            }
        }
        .offset(y: buttonsOffset)
        .opacity(buttonsOpacity)
    }

    // MARK: - Sign In Link

    private var signInLink: some View {
        Button(action: onSignIn) {
            HStack(spacing: TandemSpacing.xs) {
                Text("Already have an account?")
                    .foregroundColor(TandemColors.textSecondary)
                Text("Sign In")
                    .foregroundColor(TandemColors.primary)
                    .fontWeight(.semibold)
            }
            .font(TandemFonts.caption)
        }
        .opacity(signInOpacity)
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
            heartScale = 1.0
            heartOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
            featuresOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.7)) {
            buttonsOffset = 0
            buttonsOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.85)) {
            signInOpacity = 1.0
        }

        // Start pulsing after entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPulsing = true
        }
    }
}

// MARK: - Feature Highlight Row

private struct FeatureHighlightRow: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: TandemSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 46, height: 46)

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
        .padding(.vertical, TandemSpacing.xs)
        .padding(.horizontal, TandemSpacing.sm)
    }
}

#Preview {
    WelcomeView(
        onGetStarted: {},
        onEnterCode: {},
        onSignIn: {}
    )
}
