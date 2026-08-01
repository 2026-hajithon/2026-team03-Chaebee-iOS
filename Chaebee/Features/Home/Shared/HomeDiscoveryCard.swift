import SwiftUI

struct HomeDiscoveryCard: View {
    let discovery: HomeDiscoverySummary

    var body: some View {
        HStack(alignment: .center, spacing: CBSpacing.medium) {
            Image(discovery.iconAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: CBSpacing.xSmall) {
                Text(verbatim: discovery.timing)
                    .cbTypography(.body1)
                    .foregroundStyle(CBColor.gray6)

                Text(verbatim: discovery.title)
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.gray8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .layoutPriority(1)

                Text(verbatim: discovery.content)
                    .cbTypography(.body2)
                    .foregroundStyle(CBColor.gray7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(CBSpacing.medium)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
        .accessibilityElement(children: .combine)
    }
}
