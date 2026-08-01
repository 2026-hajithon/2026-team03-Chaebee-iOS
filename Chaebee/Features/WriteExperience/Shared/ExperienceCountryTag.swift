import SwiftUI

/// A country label used across the write-experience flow.
struct ExperienceCountryTag: View {
    private let name: LocalizedStringResource
    private let flag: ImageResource

    init(
        name: LocalizedStringResource,
        flag: ImageResource
    ) {
        self.name = name
        self.flag = flag
    }

    var body: some View {
        HStack(spacing: CBSpacing.small) {
            Image(flag)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 15)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            Text(name)
                .cbTypography(.body4)
                .foregroundStyle(CBColor.gray8)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(CBColor.gray2, in: Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    ExperienceCountryTag(
        name: "country.us",
        flag: .flagUS
    )
    .padding()
}
