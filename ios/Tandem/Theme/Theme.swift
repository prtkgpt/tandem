import SwiftUI

// MARK: - Colors

struct TandemColors {
    static let primary = Color(hex: "FF6B6B")
    static let secondary = Color(hex: "4ECDC4")
    static let background = Color(hex: "F7F7F7")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    static let accent = Color(hex: "E8A87C")
}

// MARK: - Spacing

struct TandemSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Corner Radius

struct TandemCornerRadius {
    static let card: CGFloat = 16
    static let button: CGFloat = 12
    static let small: CGFloat = 8
}

// MARK: - Fonts

struct TandemFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
}

// MARK: - Gradient

struct TandemGradient: View {
    var startPoint: UnitPoint = .topLeading
    var endPoint: UnitPoint = .bottomTrailing

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF,
                255
            )
        case 8:
            (r, g, b, a) = (
                (int >> 24) & 0xFF,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
