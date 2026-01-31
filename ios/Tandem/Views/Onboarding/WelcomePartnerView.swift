import SwiftUI

struct WelcomePartnerView: View {
    let senderName: String
    let onContinue: () -> Void

    @State private var heartScale: CGFloat = 0.2
    @State private var heartOpacity: Double = 0
    @State private var heartRotation: Double = -15
    @State private var isPulsing = false
    @State private var nameOpacity: Double = 0
    @State private var nameOffset: CGFloat = 20
    @State private var quoteOpacity: Double = 0
    @State private var quoteOffset: CGFloat = 15
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 20
    @State private var sparkleOpacity: Double = 0

    private let romanticQuotes: [String] = [
        "Together, you make this world more beautiful",
        "Every love story is beautiful, but yours is our favorite",
        "Two hearts, one journey \u{2014} let\u{2019}s begin",
        "The best things in life are better shared with you",
        "Your love story deserves its own space",
        "Some things are better together \u{2014} like the two of you",
        "Love brought you here, and we\u{2019}ll help you keep it strong",
        "Hand in hand, heart to heart \u{2014} your adventure starts now",
        "Because the greatest thing you\u{2019}ll ever learn is to love and be loved",
        "You are each other\u{2019}s greatest adventure"
    ]

    private var selectedQuote: String {
        // Use senderName hash for consistent quote per partner
        let index = abs(senderName.hashValue) % romanticQuotes.count
        return romanticQuotes[index]
    }

    var body: some View {
        ZStack {
            // MARK: - Gradient Background
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Heart Animation
                heartSection
                    .padding(.bottom, TandemSpacing.xl + TandemSpacing.sm)

                // MARK: - Invitation Message
                invitationSection
                    .padding(.bottom, TandemSpacing.lg)

                // MARK: - Romantic Quote
                quoteSection
                    .padding(.horizontal, TandemSpacing.xl)

                Spacer()
                Spacer()

                // MARK: - Continue Button
                continueButton
                    .padding(.horizontal, TandemSpacing.xl)
                    .padding(.bottom, TandemSpacing.xl + TandemSpacing.md)
            }
        }
        .onAppear {
            animateEntrance()
        }
    }

    // MARK: - Background Gradient

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                TandemColors.primary.opacity(0.08),
                TandemColors.accent.opacity(0.12),
                TandemColors.background,
                TandemColors.background
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Heart Section

    private var heartSection: some View {
        ZStack {
            // Sparkle particles (decorative)
            sparkleParticles
                .opacity(sparkleOpacity)

            // Pulsing outer ring
            Circle()
                .fill(TandemColors.primary.opacity(0.1))
                .frame(width: 170, height: 170)
                .scaleEffect(isPulsing ? 1.2 : 0.9)
                .animation(
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: isPulsing
                )

            // Second ring
            Circle()
                .fill(TandemColors.primary.opacity(0.15))
                .frame(width: 135, height: 135)
                .scaleEffect(isPulsing ? 1.05 : 0.95)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3),
                    value: isPulsing
                )

            // Main heart circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            TandemColors.primary,
                            TandemColors.accent.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: TandemColors.primary.opacity(0.5), radius: 30, x: 0, y: 12)

            // Double heart icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        }
        .scaleEffect(heartScale)
        .opacity(heartOpacity)
        .rotationEffect(.degrees(heartRotation))
    }

    // MARK: - Sparkle Particles

    private var sparkleParticles: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: [12, 8, 10, 14, 9, 11][index]))
                    .foregroundColor(
                        [TandemColors.primary, TandemColors.accent, TandemColors.secondary,
                         TandemColors.primary, TandemColors.accent, TandemColors.secondary][index]
                            .opacity(0.6)
                    )
                    .offset(
                        x: [CGFloat(-70), 75, -55, 65, -40, 50][index],
                        y: [CGFloat(-50), -35, 40, 30, -65, 55][index]
                    )
                    .scaleEffect(isPulsing ? 1.3 : 0.7)
                    .animation(
                        .easeInOut(duration: Double([1.8, 2.2, 1.6, 2.0, 1.9, 2.1][index]))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isPulsing
                    )
            }
        }
    }

    // MARK: - Invitation Section

    private var invitationSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            Text("\(senderName) invited you")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(TandemColors.textPrimary)

            Text("to Tandem")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .multilineTextAlignment(.center)
        .opacity(nameOpacity)
        .offset(y: nameOffset)
    }

    // MARK: - Quote Section

    private var quoteSection: some View {
        VStack(spacing: TandemSpacing.md) {
            // Decorative quote mark
            Image(systemName: "quote.opening")
                .font(.system(size: 24))
                .foregroundColor(TandemColors.primary.opacity(0.3))

            Text(selectedQuote)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, TandemSpacing.md)
        .opacity(quoteOpacity)
        .offset(y: quoteOffset)
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button(action: onContinue) {
            HStack(spacing: TandemSpacing.sm) {
                Text("Continue to Sign Up")
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .tandemButton()
        }
        .opacity(buttonOpacity)
        .offset(y: buttonOffset)
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        // Heart bounces in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) {
            heartScale = 1.0
            heartOpacity = 1.0
            heartRotation = 0
        }

        // Name fades in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            nameOpacity = 1.0
            nameOffset = 0
        }

        // Quote fades in
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            quoteOpacity = 1.0
            quoteOffset = 0
        }

        // Button slides up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.05)) {
            buttonOpacity = 1.0
            buttonOffset = 0
        }

        // Sparkles appear and pulsing starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                sparkleOpacity = 1.0
            }
            isPulsing = true
        }
    }
}

#Preview {
    WelcomePartnerView(
        senderName: "Alex",
        onContinue: {}
    )
}
