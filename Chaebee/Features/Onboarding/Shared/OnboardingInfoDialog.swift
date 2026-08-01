import SwiftUI

/// A custom in-app dialog displayed above onboarding content.
/// This intentionally does not use SwiftUI's system `Alert` or `confirmationDialog`.
struct OnboardingInfoDialog: View {
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.16)
                .opacity(0.9)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: CBSpacing.large) {
                VStack(alignment: .leading, spacing: CBSpacing.medium) {
                    Text("onboarding.passport.info.title")
                        .cbTypography(.head3)
                        .foregroundStyle(CBColor.gray9)

                    Text("onboarding.passport.info.body")
                        .cbTypography(.body3)
                        .foregroundStyle(CBColor.gray9)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: onConfirm) {
                    Text("common.confirm")
                        .cbTypography(.head2)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(CBColor.blue5, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white.opacity(0.78))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.72), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.28), radius: 24, y: 12)
            }
            .frame(maxWidth: 300)
            .padding(.horizontal, CBSpacing.xLarge)
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    OnboardingInfoDialog(onConfirm: {})
        .environment(\.locale, Locale(identifier: "ko"))
}
