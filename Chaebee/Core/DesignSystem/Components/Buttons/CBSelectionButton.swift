import SwiftUI

struct CBSelectionButton: View {
    enum State: Equatable {
        case selectable
        case selected
        case disabled
    }

    let title: LocalizedStringResource
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CBSpacing.small) {
                Text(title)
                    .cbTypography(.body4)
                    .lineLimit(1)

                Spacer(minLength: CBSpacing.small)

                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, CBSpacing.medium)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(CBSelectionButtonStyle(state: state))
        .disabled(state == .disabled)
    }

    private var foregroundColor: Color {
        switch state {
        case .selected: CBColor.blue5
        case .selectable: CBColor.gray8
        case .disabled: CBColor.gray4
        }
    }
}

private struct CBSelectionButtonStyle: ButtonStyle {
    let state: CBSelectionButton.State

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.medium)
                    .strokeBorder(
                        state == .selected ? CBColor.blue5 : CBColor.gray3,
                        lineWidth: state == .selected ? 1.5 : 1
                    )
            }
            .animation(
                .easeOut(duration: CBAnimation.quickDuration),
                value: configuration.isPressed
            )
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch state {
        case .selected: CBColor.blue1
        case .selectable: isPressed ? CBColor.gray2 : Color.white
        case .disabled: Color.white
        }
    }
}

#Preview {
    VStack(spacing: CBSpacing.medium) {
        CBSelectionButton(title: "혼자 여행", state: .selectable, action: {})
        CBSelectionButton(title: "혼자 여행", state: .selected, action: {})
        CBSelectionButton(title: "혼자 여행", state: .disabled, action: {})
    }
    .padding()
}
