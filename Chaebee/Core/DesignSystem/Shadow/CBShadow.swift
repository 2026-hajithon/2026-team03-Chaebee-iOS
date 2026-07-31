import SwiftUI

/// Shadow value token. Describes shadow parameters only; applying it is left to views.
struct CBShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension CBShadow {
    static let subtle = CBShadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let floating = CBShadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
}
