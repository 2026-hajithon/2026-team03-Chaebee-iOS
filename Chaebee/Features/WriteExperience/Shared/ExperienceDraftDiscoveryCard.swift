import SwiftUI

struct ExperienceDraftDiscoveryCard: View {
    let discovery: ExperienceDraftDiscovery
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    init(
        discovery: ExperienceDraftDiscovery,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.discovery = discovery
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onEdit ?? {}) {
                cardContent
            }
            .buttonStyle(.plain)
            .allowsHitTesting(onEdit != nil)

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(CBColor.blue5)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(12)
                .accessibilityLabel(Text("writeExperience.discovery.delete"))
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Text(verbatim: plainTagName)
                .cbTypography(.head2)
                .foregroundStyle(CBColor.blue5)
                .padding(.trailing, onDelete == nil ? 0 : CBSpacing.xLarge)

            Text(verbatim: discovery.content)
                .cbTypography(.body3)
                .foregroundStyle(CBColor.gray8)
                .lineLimit(2)
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CBColor.blue1)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
    }

    private var plainTagName: String {
        let localizedName = String(localized: discovery.tag.localizedName)
        return localizedName.hasPrefix("#")
            ? String(localizedName.dropFirst())
            : localizedName
    }
}
