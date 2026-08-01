import SwiftUI

/// A selectable keyword chip shared across the write-experience flow.
struct ExperienceKeywordChip: View {
    enum State: Equatable {
        case selectable
        case selected
        case disabled
    }

    private let title: LocalizedStringResource
    private let icon: ImageResource
    private let state: State
    private let action: (() -> Void)?

    init(
        title: LocalizedStringResource,
        icon: ImageResource,
        state: State,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: CBSpacing.xSmall) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .opacity(state == .disabled ? 0.4 : 1)

                Text(verbatim: displayTitle)
                    .cbTypography(.body4)
                    .lineLimit(1)
            }
        }
        .buttonStyle(ExperienceKeywordChipStyle(state: state))
        .disabled(state == .disabled)
        .allowsHitTesting(action != nil && state != .disabled)
    }

    private var displayTitle: String {
        let localizedTitle = String(localized: title)
        return localizedTitle.hasPrefix("#")
            ? String(localizedTitle.dropFirst())
            : localizedTitle
    }
}

private struct ExperienceKeywordChipStyle: ButtonStyle {
    let state: ExperienceKeywordChip.State
    var previewIsPressed = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = previewIsPressed || configuration.isPressed

        configuration.label
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(backgroundColor(isPressed: isPressed), in: Capsule())
            .overlay {
                if state == .selected {
                    Capsule()
                        .strokeBorder(CBColor.blue5, lineWidth: 1.5)
                }
            }
            .contentShape(Capsule())
            .animation(
                .easeOut(duration: CBAnimation.quickDuration),
                value: isPressed
            )
    }

    private var foregroundColor: Color {
        switch state {
        case .selected:
            CBColor.blue5
        case .selectable:
            CBColor.gray8
        case .disabled:
            CBColor.gray4
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch state {
        case .selected:
            CBColor.blue1
        case .selectable:
            isPressed ? CBColor.gray3 : CBColor.gray2
        case .disabled:
            CBColor.gray1
        }
    }
}

#Preview("Experience keyword chip 4 variants") {
    VStack(alignment: .leading, spacing: CBSpacing.large) {
        ExperienceKeywordChip(
            title: "레이블",
            icon: .boardingPass,
            state: .selectable,
            action: {}
        )

        previewPressedExperienceKeywordChip

        ExperienceKeywordChip(
            title: "레이블",
            icon: .boardingPass,
            state: .selected,
            action: {}
        )

        ExperienceKeywordChip(
            title: "레이블",
            icon: .boardingPass,
            state: .disabled,
            action: {}
        )
    }
    .padding(CBSpacing.pageHorizontal)
}

private var previewPressedExperienceKeywordChip: some View {
    Button(action: {}) {
        HStack(spacing: CBSpacing.xSmall) {
            Image(.boardingPass)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text(verbatim: "레이블")
                .cbTypography(.body4)
        }
    }
    .buttonStyle(
        ExperienceKeywordChipStyle(
            state: .selectable,
            previewIsPressed: true
        )
    )
}
