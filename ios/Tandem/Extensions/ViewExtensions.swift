import SwiftUI

// MARK: - Tandem Card Modifier

struct TandemCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(TandemSpacing.md)
            .background(TandemColors.cardBackground)
            .cornerRadius(TandemCornerRadius.card)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
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
            .background(
                TandemGradient()
            )
            .cornerRadius(TandemCornerRadius.button)
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
            .background(Color.clear)
            .cornerRadius(TandemCornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                    .stroke(TandemColors.primary, lineWidth: 2)
            )
    }
}

// MARK: - View Extensions

extension View {

    /// Applies the Tandem card style: white background, rounded corners, and a subtle shadow.
    func tandemCard() -> some View {
        modifier(TandemCardModifier())
    }

    /// Applies the Tandem primary button style: gradient background, white text, rounded corners.
    func tandemButton() -> some View {
        modifier(TandemButtonModifier())
    }

    /// Applies the Tandem secondary button style: outlined with primary color.
    func tandemSecondaryButton() -> some View {
        modifier(TandemSecondaryButtonModifier())
    }
}
