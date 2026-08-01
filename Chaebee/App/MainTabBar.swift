import SwiftUI

struct MainTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(CBSpacing.xSmall)
        .frame(height: 64)
        .background(Color.white, in: Capsule())
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 18,
            x: 0,
            y: 8
        )
    }

    private func tabButton(_ tab: MainTab) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 2) {
                tabIcon(tab)
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .cbTypography(.subhead1)
                    .lineLimit(1)
            }
            .foregroundStyle(selection == tab ? CBColor.blue5 : CBColor.gray9)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                if selection == tab {
                    Capsule()
                        .fill(CBColor.gray2)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }

    @ViewBuilder
    private func tabIcon(_ tab: MainTab) -> some View {
        Image(tab.iconResource)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
    }
}
