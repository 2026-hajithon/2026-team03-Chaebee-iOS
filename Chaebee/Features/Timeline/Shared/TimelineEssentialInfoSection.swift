import SwiftUI

struct TimelineEssentialInfoSection: View {
    let info: TimelineEssentialInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("timeline.essentialInfo.title")
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray9)
                .padding(.bottom, CBSpacing.medium)

            infoRow("timeline.essentialInfo.passportValidity", value: info.passportValidityRule)
            Divider().overlay(CBColor.gray3)
            infoRow("timeline.essentialInfo.visaFreeStay", value: info.visaFreeStayDescription)
            Divider().overlay(CBColor.gray3)

            HStack {
                Text("timeline.essentialInfo.officialSite")
                    .cbTypography(.subhead2)
                    .foregroundStyle(CBColor.gray8)

                Spacer()

                Link(destination: info.officialSiteURL) {
                    HStack(spacing: CBSpacing.xSmall) {
                        Text(verbatim: info.officialSiteName)
                        Image(systemName: "arrow.up.right")
                    }
                    .cbTypography(.body2)
                    .foregroundStyle(CBColor.blue5)
                }
            }
            .frame(minHeight: 48)

            Divider().overlay(CBColor.gray3)
            infoRow("timeline.essentialInfo.lastUpdated", value: info.lastUpdatedDescription)

            Text("timeline.essentialInfo.disclaimer")
                .cbTypography(.caption1)
                .foregroundStyle(CBColor.gray5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, CBSpacing.medium)
        }
    }

    private func infoRow(
        _ title: LocalizedStringResource,
        value: String
    ) -> some View {
        HStack(spacing: CBSpacing.medium) {
            Text(title)
                .cbTypography(.subhead2)
                .foregroundStyle(CBColor.gray8)

            Spacer()

            Text(verbatim: value)
                .cbTypography(.body2)
                .foregroundStyle(CBColor.gray7)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: 48)
    }
}
