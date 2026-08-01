import SwiftUI

/// A status badge shared within the trip registration flow.
struct ComingSoonBadge: View {
    var body: some View {
        Text("common.comingSoon")
            .cbTypography(.head1)
            .foregroundStyle(CBColor.gray7)
            .padding(.horizontal, CBSpacing.xSmall)
            .padding(.vertical, 2)
            .background(CBColor.gray3, in: Capsule())
            .fixedSize()
    }
}

#Preview {
    ComingSoonBadge()
        .padding()
}
