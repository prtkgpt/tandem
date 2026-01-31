import SwiftUI

// MARK: - Colors

struct TandemColors {
    // Core palette
    static let primary = Color(hex: "FF6B6B")        // Rich warm coral/rose
    static let secondary = Color(hex: "2EC4B6")       // Warm teal
    static let accent = Color(hex: "FFB347")           // Warm amber/gold
    static let background = Color(hex: "FFF8F5")       // Warm off-white
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "1A1A2E")      // Rich dark
    static let textSecondary = Color(hex: "6B7280")    // Warm gray

    // Section-specific colors
    static let topicColor = Color(hex: "8B5CF6")       // Soft purple
    static let appreciationColor = Color(hex: "EC4899") // Warm pink
    static let timeColor = Color(hex: "3B82F6")         // Ocean blue
    static let dateNightColor = Color(hex: "F59E0B")    // Amber
    static let goalColor = Color(hex: "10B981")         // Emerald
    static let nudgeColor = Color(hex: "A78BFA")        // Soft lavender
    static let boardColor = Color(hex: "F97316")         // Warm orange
    static let calendarColor = Color(hex: "6366F1")      // Indigo
    static let moodColor = Color(hex: "F472B6")          // Rose pink

    // Surface colors for subtle backgrounds
    static let surfacePrimary = Color(hex: "FF6B6B").opacity(0.08)
    static let surfaceSecondary = Color(hex: "2EC4B6").opacity(0.08)
    static let surfaceAccent = Color(hex: "FFB347").opacity(0.10)
    static let surfaceTopic = Color(hex: "8B5CF6").opacity(0.08)
    static let surfaceAppreciation = Color(hex: "EC4899").opacity(0.08)
    static let surfaceTime = Color(hex: "3B82F6").opacity(0.08)

    // Divider & border
    static let divider = Color(hex: "E5E7EB")
    static let border = Color(hex: "F3F4F6")
}

// MARK: - Spacing

struct TandemSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

struct TandemCornerRadius {
    static let small: CGFloat = 8
    static let button: CGFloat = 14
    static let card: CGFloat = 20
    static let large: CGFloat = 28
    static let pill: CGFloat = 100
}

// MARK: - Fonts

struct TandemFonts {
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 15, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
    static let captionBold = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let micro = Font.system(size: 11, weight: .medium, design: .rounded)
}

// MARK: - Gradient

struct TandemGradient: View {
    var startPoint: UnitPoint = .topLeading
    var endPoint: UnitPoint = .bottomTrailing

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                TandemColors.primary,
                Color(hex: "FF8E8E"),
                TandemColors.accent,
            ]),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - Named Gradients

struct TandemGradients {
    /// Warm coral-to-amber hero gradient for headers
    static let warmSunrise = LinearGradient(
        colors: [
            Color(hex: "FF6B6B"),
            Color(hex: "FF8E53"),
            Color(hex: "FFB347"),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Soft pink-to-peach for appreciation sections
    static let roseGold = LinearGradient(
        colors: [
            Color(hex: "EC4899").opacity(0.85),
            Color(hex: "F472B6"),
            Color(hex: "FBBF24").opacity(0.6),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Topic purple-to-blue
    static let deepThought = LinearGradient(
        colors: [
            Color(hex: "8B5CF6"),
            Color(hex: "6366F1"),
            Color(hex: "3B82F6"),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Ocean blue for time sections
    static let oceanBreeze = LinearGradient(
        colors: [
            Color(hex: "3B82F6"),
            Color(hex: "06B6D4"),
            Color(hex: "2EC4B6"),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle warm surface gradient for card backgrounds
    static let warmSurface = LinearGradient(
        colors: [
            Color(hex: "FFF8F5"),
            Color(hex: "FFF1EB"),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glassmorphism overlay
    static let glassOverlay = LinearGradient(
        colors: [
            Color.white.opacity(0.25),
            Color.white.opacity(0.05),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadow Styles

struct TandemShadow {
    static let card = (color: Color.black.opacity(0.06), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
    static let cardHover = (color: Color.black.opacity(0.10), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(8))
    static let button = (color: Color(hex: "FF6B6B").opacity(0.30), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
    static let soft = (color: Color.black.opacity(0.04), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
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
