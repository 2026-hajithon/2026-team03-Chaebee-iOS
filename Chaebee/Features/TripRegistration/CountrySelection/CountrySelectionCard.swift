import SwiftUI

/// A country card used only by `CountrySelectionView`.
struct CountrySelectionCard: View {
    enum State: Equatable {
        case selectable
        case navigable
        case selected
        case comingSoon
    }

    private let name: LocalizedStringKey
    private let flag: ImageResource
    private let state: State
    private let action: () -> Void

    init(
        name: LocalizedStringKey,
        flag: ImageResource,
        state: State,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.flag = flag
        self.state = state
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            CountrySelectionCardContent(
                name: name,
                flag: flag,
                state: state
            )
        }
        .buttonStyle(CountrySelectionCardStyle(state: state))
        .disabled(state == .comingSoon)
    }
}

private struct CountrySelectionCardContent: View {
    let name: LocalizedStringKey
    let flag: ImageResource
    let state: CountrySelectionCard.State

    private var nameColor: Color {
        switch state {
        case .selected:
            CBColor.blue5
        case .comingSoon:
            CBColor.gray4
        case .selectable, .navigable:
            CBColor.gray8
        }
    }

    private var flagOpacity: Double {
        state == .comingSoon ? 0.4 : 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(flag)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .opacity(flagOpacity)

            Spacer(minLength: 0)

            Text(name)
                .cbTypography(.head2)
                .foregroundStyle(nameColor)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 96)
        .overlay(alignment: .trailing) {
            accessory
                .padding(.trailing, CBSpacing.medium)
        }
        .overlay(alignment: .topTrailing) {
            if state == .comingSoon {
                ComingSoonBadge()
                    .padding(14)
            }
        }
    }

    @ViewBuilder
    private var accessory: some View {
        switch state {
        case .selectable:
            Image(systemName: "checkmark")
                .foregroundStyle(CBColor.gray3)
        case .navigable:
            Image(systemName: "chevron.right")
                .foregroundStyle(CBColor.gray6)
        case .selected:
            Image(systemName: "checkmark")
                .foregroundStyle(CBColor.blue5)
        case .comingSoon:
            EmptyView()
        }
    }

}

private struct CountrySelectionCardStyle: ButtonStyle {
    let state: CountrySelectionCard.State
    var previewIsPressed = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = previewIsPressed || configuration.isPressed

        configuration.label
            .background(backgroundColor(isPressed: isPressed))
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.large)
                    .strokeBorder(borderColor, lineWidth: state == .selected ? 1.5 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: CBRadius.large))
            .animation(
                .easeOut(duration: CBAnimation.quickDuration),
                value: isPressed
            )
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch state {
        case .selected:
            CBColor.blue1
        case .selectable, .navigable:
            isPressed ? CBColor.gray2 : Color.white
        case .comingSoon:
            Color.white
        }
    }

    private var borderColor: Color {
        state == .selected ? CBColor.blue5 : CBColor.gray3
    }
}

#Preview("Country card 5 variants") {
    VStack(spacing: CBSpacing.medium) {
        CountrySelectionCard(
            name: "country.jp",
            flag: .flagJP,
            state: .selectable,
            action: {}
        )

        previewPressedCountryCard

        CountrySelectionCard(
            name: "country.us",
            flag: .flagUS,
            state: .navigable,
            action: {}
        )

        CountrySelectionCard(
            name: "country.tw",
            flag: .flagTW,
            state: .selected,
            action: {}
        )

        CountrySelectionCard(
            name: "country.jp",
            flag: .flagJP,
            state: .comingSoon,
            action: {}
        )
    }
    .padding(CBSpacing.pageHorizontal)
    .background(CBColor.backgroundPrimary)
}

private var previewPressedCountryCard: some View {
    Button(action: {}) {
        CountrySelectionCardContent(
            name: "country.jp",
            flag: .flagJP,
            state: .selectable
        )
    }
    .buttonStyle(
        CountrySelectionCardStyle(
            state: .selectable,
            previewIsPressed: true
        )
    )
}
