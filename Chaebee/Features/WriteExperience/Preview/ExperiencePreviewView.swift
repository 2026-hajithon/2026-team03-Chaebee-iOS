import SwiftUI

struct ExperiencePreviewView: View {
    @Environment(\.dismiss) private var dismiss

    let draft: WriteExperienceDraft

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBSpacing.large) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(CBColor.gray9)
                        .frame(width: 44, height: 44)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)

                Text("writeExperience.preview.title")
                    .cbTypography(.head5)
                    .foregroundStyle(CBColor.gray9)

                if let location = draft.location {
                    Text(verbatim: locationDisplayName(location))
                        .cbTypography(.head3)
                        .foregroundStyle(CBColor.gray8)
                }

                ForEach(draft.discoveries) { discovery in
                    ExperienceDraftDiscoveryCard(
                        discovery: discovery
                    )
                }
            }
            .padding(CBSpacing.pageHorizontal)
        }
        .background(CBColor.gray1)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func locationDisplayName(_ location: ExperienceLocation) -> String {
        let countryName = String(localized: location.country.localizedName)
        return "\(location.cityName), \(countryName)"
    }
}

#Preview {
    NavigationStack {
        ExperiencePreviewView(
            draft: WriteExperienceDraft(
                location: ExperienceLocation(
                    id: 101,
                    cityName: "로스앤젤레스",
                    country: .us
                ),
                travelType: .solo,
                discoveries: [
                    ExperienceDraftDiscovery(
                        tag: .visa,
                        content: "ESTA 신청 전에 여권 정보를 확인하세요."
                    )
                ]
            )
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
