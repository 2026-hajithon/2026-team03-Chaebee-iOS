import CoreGraphics

/// Corner radius scale.
/// For fully rounded (pill) shapes, prefer SwiftUI's `Capsule` over a large radius.
enum CBRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 20
    /// Fallback value only; use `Capsule` for pill shapes.
    static let capsule: CGFloat = 999
}
