import SwiftUI

/// Semantic color tokens.
/// Brand values are not final, so these fall back to system semantic colors.
enum CBColor {
    // TODO: Replace with the brand primary color once provided.
    static let brandPrimary = Color.accentColor
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let borderDefault = Color(uiColor: .separator)
    static let disabled = Color(uiColor: .tertiaryLabel)
}
