import SwiftUI

/// Semantic typography tokens built on system Dynamic Type styles.
enum CBTypography {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let headline = Font.headline
    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let caption = Font.caption
}
