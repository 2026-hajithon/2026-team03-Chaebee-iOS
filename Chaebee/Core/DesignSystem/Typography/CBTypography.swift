import CoreText
import SwiftUI
import UIKit

/// Typography tokens shared across Chaebee.
///
/// Korean uses Interop when the matching font files are bundled in the app.
/// English uses the iOS system font (SF Pro). If Interop is unavailable, the
/// token safely falls back to the system font.
enum CBTypography {
    enum Style: CaseIterable {
        case head1
        case head2
        case head3
        case head4
        case head5

        case subhead1
        case subhead2
        case subhead3
        case subhead4
        case subhead5

        case body1
        case body2
        case body3
        case body4
        case body5

        case caption1

        var size: CGFloat {
            switch self {
            case .head1, .subhead2, .body2:
                12
            case .head2, .subhead4, .body4:
                16
            case .head3, .subhead5, .body5:
                20
            case .head4:
                24
            case .head5:
                30
            case .subhead1, .body1, .caption1:
                11
            case .subhead3, .body3:
                14
            }
        }

        var lineHeight: CGFloat {
            size * lineHeightRatio
        }

        fileprivate var lineHeightRatio: CGFloat {
            switch self {
            case .head1, .head2, .head3, .head4, .head5:
                1.3
            case .subhead1, .subhead2, .subhead3, .subhead4, .subhead5,
                 .body1, .body2, .body3, .body4, .body5, .caption1:
                1.4
            }
        }

        fileprivate var weight: FontWeight {
            switch self {
            case .head1, .head2, .head3, .head4, .head5:
                .bold
            case .subhead1, .subhead2, .subhead3, .subhead4, .subhead5:
                .semibold
            case .body1, .body2, .body3, .body4, .body5, .caption1:
                .regular
            }
        }

        fileprivate func uiFont(for locale: Locale) -> UIFont {
            if locale.language.languageCode?.identifier == "ko" {
                InteropFontRegistrar.registerFontsIfNeeded()

                if let interopFont = UIFont(name: weight.interopPostScriptName, size: size) {
                    return interopFont
                }
            }

            return UIFont.systemFont(ofSize: size, weight: weight.uiFontWeight)
        }
    }

    fileprivate enum FontWeight {
        case regular
        case semibold
        case bold

        var interopPostScriptName: String {
            switch self {
            case .regular:
                "Interop-Regular"
            case .semibold:
                "Interop-SemiBold"
            case .bold:
                "Interop-Bold"
            }
        }

        var uiFontWeight: UIFont.Weight {
            switch self {
            case .regular:
                .regular
            case .semibold:
                .semibold
            case .bold:
                .bold
            }
        }
    }
}

private enum InteropFontRegistrar {
    private static let registration: Void = {
        ["Interop-Regular", "Interop-SemiBold", "Interop-Bold"].forEach { resourceName in
            guard let fontURL = Bundle.main.url(forResource: resourceName, withExtension: "otf") else {
                return
            }

            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }()

    static func registerFontsIfNeeded() {
        _ = registration
    }
}

private struct CBTypographyModifier: ViewModifier {
    @Environment(\.locale) private var locale

    let style: CBTypography.Style

    func body(content: Content) -> some View {
        let uiFont = style.uiFont(for: locale)

        content
            .font(Font(uiFont))
            .lineSpacing(max(0, style.lineHeight - uiFont.lineHeight))
    }
}

extension View {
    /// Applies a Chaebee typography token using the current app locale.
    func cbTypography(_ style: CBTypography.Style) -> some View {
        modifier(CBTypographyModifier(style: style))
    }
}
