import SwiftUI

/// The shared top header used by the main tab screens.
struct CBAppHeader: View {
    var onNotificationsTap: () -> Void = {}

    var body: some View {
        HStack {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 44, alignment: .leading)

            Spacer()

            Button(action: onNotificationsTap) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(CBColor.gray4)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("common.notifications"))
        }
    }
}

#Preview {
    CBAppHeader()
        .padding(CBSpacing.pageHorizontal)
}
