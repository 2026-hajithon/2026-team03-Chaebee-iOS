import SwiftUI

struct HomeTripCard: View {
    let trip: HomeTripSummary
    let layout: Layout
    let isEditing: Bool
    let onDelete: () -> Void

    enum Layout {
        case grid
        case single
    }

    init(
        trip: HomeTripSummary,
        layout: Layout = .grid,
        isEditing: Bool = false,
        onDelete: @escaping () -> Void = {}
    ) {
        self.trip = trip
        self.layout = layout
        self.isEditing = isEditing
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image(trip.flagAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))

                Spacer()

                if isEditing {
                    Button(action: onDelete) {
                        Image(.trashX)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundStyle(CBColor.gray5)
                            .frame(width: 24, height: 24)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("home.deleteTrip.confirm"))
                } else {
                    Text(verbatim: "D-\(trip.dDay)")
                        .cbTypography(.subhead1)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, CBSpacing.small)
                        .frame(height: 24)
                        .background(CBColor.blue5)
                        .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
                }
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
        .frame(
            maxWidth: .infinity,
            minHeight: layout == .single ? 156 : 184,
            alignment: .topLeading
        )
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
        .accessibilityElement(children: .combine)
    }
}
