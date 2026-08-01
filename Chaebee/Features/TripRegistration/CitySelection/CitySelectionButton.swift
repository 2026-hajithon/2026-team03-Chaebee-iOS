import SwiftUI

/// A city option used only by the city selection step.
struct CitySelectionButton: View {
    enum State: Equatable {
        case selectable
        case selected
        case disabled
        case comingSoon
    }

    private let name: LocalizedStringKey
    private let state: State
    private let action: () -> Void

    init(
        name: LocalizedStringKey,
        state: State,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            CitySelectionButtonContent(name: name, state: state)
        }
        .buttonStyle(CitySelectionButtonStyle(state: state))
        .disabled(state == .disabled || state == .comingSoon)
    }
}

private struct CitySelectionButtonContent: View {
    let name: LocalizedStringKey
    let state: CitySelectionButton.State

    private var foregroundColor: Color {
        switch state {
        case .selected:
            CBColor.blue5
        case .disabled, .comingSoon:
            CBColor.gray4
        case .selectable:
            CBColor.gray8
        }
    }

    var body: some View {
        HStack(spacing: CBSpacing.small) {
            Text(name)
                .cbTypography(.head2)
                .lineLimit(1)

            if state == .comingSoon {
                ComingSoonBadge()
            }

            Spacer(minLength: CBSpacing.small)

            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .semibold))
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, CBSpacing.medium)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .contentShape(Rectangle())
    }
}

private struct CitySelectionButtonStyle: ButtonStyle {
    let state: CitySelectionButton.State
    var previewIsPressed = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = previewIsPressed || configuration.isPressed

        configuration.label
            .background(backgroundColor(isPressed: isPressed))
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.medium)
                    .strokeBorder(borderColor, lineWidth: state == .selected ? 1.5 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            .animation(
                .easeOut(duration: CBAnimation.quickDuration),
                value: isPressed
            )
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch state {
        case .selected:
            CBColor.blue1
        case .selectable:
            isPressed ? CBColor.gray2 : Color.white
        case .disabled, .comingSoon:
            Color.white
        }
    }

    private var borderColor: Color {
        state == .selected ? CBColor.blue5 : CBColor.gray3
    }
}

#Preview("City selection 5 variants") {
    VStack(spacing: CBSpacing.large) {
        CitySelectionButton(name: "Los Angeles", state: .selectable, action: {})

        previewPressedCitySelectionButton

        CitySelectionButton(name: "Los Angeles", state: .selected, action: {})

        CitySelectionButton(name: "New York", state: .disabled, action: {})

        CitySelectionButton(name: "Honolulu", state: .comingSoon, action: {})
    }
    .padding(CBSpacing.pageHorizontal)
    .background(CBColor.backgroundPrimary)
}

private var previewPressedCitySelectionButton: some View {
    Button(action: {}) {
        CitySelectionButtonContent(name: "Los Angeles", state: .selectable)
    }
    .buttonStyle(
        CitySelectionButtonStyle(
            state: .selectable,
            previewIsPressed: true
        )
    )
}
