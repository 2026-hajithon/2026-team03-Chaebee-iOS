import SwiftUI

/// A reusable Chaebee button supporting primary and secondary appearances.
///
/// Normal and pressed states are handled automatically. Apply SwiftUI's
/// `.disabled(_:)` modifier to display the disabled state.
struct CBButton: View {
    enum Variant {
        case primary
        case secondary
    }

    enum Size: Equatable {
        case large
        case small

        fileprivate var height: CGFloat {
            switch self {
            case .large:
                48
            case .small:
                24
            }
        }

        fileprivate var horizontalPadding: CGFloat {
            switch self {
            case .large:
                CBSpacing.medium
            case .small:
                CBSpacing.small
            }
        }

        fileprivate var cornerRadius: CGFloat {
            switch self {
            case .large:
                CBRadius.medium
            case .small:
                CBRadius.small
            }
        }

        fileprivate var typography: CBTypography.Style {
            switch self {
            case .large:
                .head2
            case .small:
                .head1
            }
        }

        fileprivate var fillsAvailableWidth: Bool {
            self == .large
        }
    }

    private let title: LocalizedStringKey
    private let variant: Variant
    private let size: Size
    private let action: () -> Void

    init(
        _ title: LocalizedStringKey,
        variant: Variant = .primary,
        size: Size = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(CBButtonStyle(variant: variant, size: size))
    }
}

private enum CBButtonVisualState: Hashable {
    case normal
    case pressed
    case disabled
}

private struct CBButtonStyle: ButtonStyle {
    let variant: CBButton.Variant
    let size: CBButton.Size
    var previewState: CBButtonVisualState?

    init(
        variant: CBButton.Variant,
        size: CBButton.Size,
        previewState: CBButtonVisualState? = nil
    ) {
        self.variant = variant
        self.size = size
        self.previewState = previewState
    }

    func makeBody(configuration: Configuration) -> some View {
        CBButtonStyleBody(
            configuration: configuration,
            variant: variant,
            size: size,
            previewState: previewState
        )
    }
}

private struct CBButtonStyleBody: View {
    @Environment(\.isEnabled) private var isEnabled

    let configuration: ButtonStyle.Configuration
    let variant: CBButton.Variant
    let size: CBButton.Size
    let previewState: CBButtonVisualState?

    private var state: CBButtonVisualState {
        if let previewState {
            return previewState
        }

        if !isEnabled {
            return .disabled
        }

        return configuration.isPressed ? .pressed : .normal
    }

    private var backgroundColor: Color {
        switch state {
        case .disabled:
            CBColor.gray3
        case .normal, .pressed:
            switch variant {
            case .primary:
                CBColor.blue5
            case .secondary:
                CBColor.blue1
            }
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .disabled:
            CBColor.gray4
        case .normal, .pressed:
            switch variant {
            case .primary:
                Color.white
            case .secondary:
                CBColor.blue5
            }
        }
    }

    private var pressedOverlayOpacity: Double {
        state == .pressed ? 0.08 : 0
    }

    var body: some View {
        configuration.label
            .cbTypography(size.typography)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: size.fillsAvailableWidth ? .infinity : nil)
            .frame(height: size.height)
            .background {
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .fill(Color.black.opacity(pressedOverlayOpacity))
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .animation(.easeOut(duration: CBAnimation.quickDuration), value: state)
    }
}

#Preview("CBButton 12 variants") {
    ScrollView {
        VStack(alignment: .leading, spacing: CBSpacing.large) {
            ForEach(
                [CBButtonVisualState.normal, .pressed, .disabled],
                id: \.self
            ) { state in
                VStack(alignment: .leading, spacing: CBSpacing.small) {
                    Text(verbatim: previewTitle(for: state))
                        .cbTypography(.caption1)
                        .foregroundStyle(CBColor.textSecondary)

                    HStack(spacing: CBSpacing.small) {
                        previewButton(variant: .primary, size: .large, state: state)
                        previewButton(variant: .secondary, size: .large, state: state)
                    }

                    HStack(spacing: CBSpacing.medium) {
                        previewButton(variant: .primary, size: .small, state: state)
                        previewButton(variant: .secondary, size: .small, state: state)
                    }
                }
            }
        }
        .padding(CBSpacing.pageHorizontal)
    }
    .background(Color.white)
}

@ViewBuilder
private func previewButton(
    variant: CBButton.Variant,
    size: CBButton.Size,
    state: CBButtonVisualState
) -> some View {
    Button(action: {}) {
        Text(verbatim: "레이블")
    }
    .buttonStyle(
        CBButtonStyle(
            variant: variant,
            size: size,
            previewState: state
        )
    )
}

private func previewTitle(for state: CBButtonVisualState) -> String {
    switch state {
    case .normal:
        "Normal"
    case .pressed:
        "Pressed"
    case .disabled:
        "Disabled"
    }
}
