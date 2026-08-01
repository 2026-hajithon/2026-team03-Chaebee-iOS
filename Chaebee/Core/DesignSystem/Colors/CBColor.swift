import SwiftUI

/// Chaebee color tokens defined in the sRGB color space.
enum CBColor {
    // MARK: - Gray

    static let gray9 = color(hex: 0x1B1D1F)
    static let gray8 = color(hex: 0x343639)
    static let gray7 = color(hex: 0x484A4D)
    static let gray6 = color(hex: 0x6B6F72)
    static let gray5 = color(hex: 0x7A7D80)
    static let gray4 = color(hex: 0xB4B7BA)
    static let gray3 = color(hex: 0xDADDE0)
    static let gray2 = color(hex: 0xEDEFF2)
    static let gray1 = color(hex: 0xF7F8FA)

    // MARK: - Blue

    /// Main brand blue.
    static let blue5 = color(hex: 0x0D8AFF)
    static let blue4 = color(hex: 0x5BABFB)
    static let blue3 = color(hex: 0x93C4F5)
    static let blue2 = color(hex: 0xBBDAF9)
    static let blue1 = color(hex: 0xD0E5FB)

    // MARK: - Status

    static let red = color(hex: 0xFF3355)
    static let orange = color(hex: 0xFF9E33)
    static let yellow = color(hex: 0xFFD433)
    static let green = color(hex: 0x29CC62)
    static let indigo = color(hex: 0x6559FF)

    // MARK: - Semantic

    static let brandPrimary = blue5
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let borderDefault = Color(uiColor: .separator)
    static let disabled = Color(uiColor: .tertiaryLabel)

    private static func color(hex: UInt32) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
