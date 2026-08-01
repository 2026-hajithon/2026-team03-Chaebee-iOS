import SwiftUI

struct TravelerDiscoveryCard: View {
    let discovery: TravelerDiscovery
    var avatarData: Data?
    var avatarColor: ExperienceAvatar?

    var body: some View {
        VStack(alignment: .leading, spacing: CBSpacing.medium) {
            HStack(spacing: CBSpacing.small) {
                discoveryAvatar

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: discovery.authorName)
                        .cbTypography(.head2)
                        .foregroundStyle(CBColor.gray8)

                    Text(discovery.createdAt, format: .relative(presentation: .named))
                        .cbTypography(.body2)
                        .foregroundStyle(CBColor.gray5)
                }

                Spacer()
            }

            Text(verbatim: discovery.content)
                .cbTypography(.body4)
                .foregroundStyle(CBColor.gray8)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: CBSpacing.small) {
                ExperienceCountryTag(
                    name: discovery.country.localizedName,
                    flag: discovery.country.flagResource
                )

                ExperienceKeywordChip(
                    title: discovery.tag.localizedName,
                    icon: discovery.tag.iconResource,
                    state: .selectable
                )
            }
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }

    @ViewBuilder
    private var discoveryAvatar: some View {
        if let avatarData, let image = UIImage(data: avatarData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        } else {
            Image((avatarColor ?? discovery.authorAvatar).imageResource)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        }
    }
}

#Preview {
    TravelerDiscoveryCard(
        discovery: TravelerDiscovery(
            id: 1,
            authorName: "안졸리나졸려",
            authorAvatar: .green,
            createdAt: .now,
            content: "비짓재팬웹 등록했다고 끝난 게 아니에요. 여권 유효기간을 확인하세요.",
            country: .jp,
            tag: .passport
        )
    )
    .padding()
    .background(CBColor.gray1)
    .environment(\.locale, Locale(identifier: "ko"))
}
