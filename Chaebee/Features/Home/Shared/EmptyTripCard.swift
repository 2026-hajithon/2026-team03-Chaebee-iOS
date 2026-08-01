import SwiftUI

struct EmptyTripCard: View {
    let onRegister: () -> Void

    init(onRegister: @escaping () -> Void = {}) {
        self.onRegister = onRegister
    }

    var body: some View {
        VStack(spacing: CBSpacing.large) {
            HStack(alignment: .center, spacing: CBSpacing.medium) {
                VStack(alignment: .leading, spacing: CBSpacing.small) {
                    Text("home.empty.eyebrow")
                        .cbTypography(.subhead3)
                        .foregroundStyle(CBColor.gray6)

                    Text("home.empty.title")
                        .cbTypography(.head3)
                        .foregroundStyle(CBColor.blue5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.boardingPass)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 112)
                    .accessibilityHidden(true)
            }

            Button(action: onRegister) {
                Text("home.registerTrip")
                    .cbTypography(.head2)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(CBColor.blue5)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            }
            .buttonStyle(.plain)
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }
}
