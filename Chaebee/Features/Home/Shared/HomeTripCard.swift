import SwiftUI

struct HomeTripCard: View {
    let trip: HomeTripSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image(trip.flagAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))

                Spacer()

                Text(verbatim: "D-\(trip.dDay)")
                    .cbTypography(.subhead1)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, CBSpacing.small)
                    .frame(height: 24)
                    .background(CBColor.blue5)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
            }

            Spacer(minLength: CBSpacing.large)

            Text(verbatim: trip.destinationName)
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray8)
                .lineLimit(2)

            Text(
                verbatim: String(
                    format: String(localized: "home.trip.progress"),
                    trip.progressPercent
                )
            )
            .cbTypography(.subhead2)
            .foregroundStyle(CBColor.blue5)
            .padding(.top, CBSpacing.xSmall)
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
        .accessibilityElement(children: .combine)
    }
}
