import SwiftUI

// MARK: - Tandem Card Modifier

struct TandemCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(TandemSpacing.md)
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

// MARK: - Section Card Modifier (with colored left border accent)

struct SectionCardModifier: ViewModifier {
    let accentColor: Color

    func body(content: Content) -> some View {
        content
            .padding(TandemSpacing.md)
            .background(TandemColors.cardBackground)
            .cornerRadius(TandemCornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                    .fill(Color.clear)
                    .overlay(alignment: .leading) {
                        UnevenRoundedRectangle(
                            topLeadingRadius: TandemCornerRadius.card,
                            bottomLeadingRadius: TandemCornerRadius.card,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                        .fill(accentColor)
                        .frame(width: 4)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: TandemCornerRadius.card))
            )
            .shadow(
                color: TandemShadow.card.color,
                radius: TandemShadow.card.radius,
                x: TandemShadow.card.x,
                y: TandemShadow.card.y
            )
    }
}

// MARK: - Glass Card Modifier (Glassmorphism)

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(TandemSpacing.md)
            .background(
                ZStack {
                    // Frosted background
                    RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                        .fill(.ultraThinMaterial)

                    // Glass gradient overlay
                    RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                        .fill(TandemGradients.glassOverlay)

                    // Subtle border
                    RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: TandemShadow.soft.color,
                radius: TandemShadow.soft.radius,
                x: TandemShadow.soft.x,
                y: TandemShadow.soft.y
            )
    }
}

// MARK: - Tandem Button Modifier

struct TandemButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(TandemFonts.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TandemSpacing.md)
            .background(TandemGradient())
            .cornerRadius(TandemCornerRadius.button)
            .shadow(
                color: TandemShadow.button.color,
                radius: TandemShadow.button.radius,
                x: TandemShadow.button.x,
                y: TandemShadow.button.y
            )
    }
}

// MARK: - Tandem Secondary Button Modifier

struct TandemSecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(TandemFonts.headline)
            .foregroundColor(TandemColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TandemSpacing.md)
            .background(TandemColors.surfacePrimary)
            .cornerRadius(TandemCornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                    .stroke(TandemColors.primary.opacity(0.3), lineWidth: 1.5)
            )
    }
}

// MARK: - Colored Icon Badge Modifier

struct ColoredIconBadge: ViewModifier {
    let color: Color
    let size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundColor(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.12))
            )
    }
}

// MARK: - Shimmer Loading Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.4),
                            Color.clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: -geo.size.width * 0.3 + phase * (geo.size.width * 1.6))
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 1
                        }
                    }
                }
                .mask(content)
            )
    }
}

// MARK: - View Extensions

extension View {

    /// Applies the Tandem card style: white background, rounded corners, and a subtle shadow.
    func tandemCard() -> some View {
        modifier(TandemCardModifier())
    }

    /// Card with a subtle left border accent in the given color. Great for section-specific cards.
    func sectionCard(color: Color) -> some View {
        modifier(SectionCardModifier(accentColor: color))
    }

    /// Glassmorphism card with frosted background, gradient overlay, and subtle border.
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }

    /// Applies the Tandem primary button style: gradient background, white text, rounded corners.
    func tandemButton() -> some View {
        modifier(TandemButtonModifier())
    }

    /// Applies the Tandem secondary button style: outlined with primary color surface fill.
    func tandemSecondaryButton() -> some View {
        modifier(TandemSecondaryButtonModifier())
    }

    /// Wraps content in a colored icon badge circle.
    func iconBadge(color: Color, size: CGFloat = 44) -> some View {
        modifier(ColoredIconBadge(color: color, size: size))
    }

    /// Adds a shimmer loading animation overlay.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
