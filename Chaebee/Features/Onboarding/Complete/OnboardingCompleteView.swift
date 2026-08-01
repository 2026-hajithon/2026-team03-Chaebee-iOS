import SwiftUI

struct OnboardingCompleteView: View {
    let onBack: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(CBColor.gray9)
                        .frame(width: 44, height: 44)
                        .background(Color.white, in: Circle())
                        .shadow(
                            color: CBShadow.subtle.color,
                            radius: CBShadow.subtle.radius,
                            x: CBShadow.subtle.x,
                            y: CBShadow.subtle.y
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("common.back"))

                Spacer()
            }

            Text("onboarding.unsupported.title")
                .cbTypography(.head4)
                .foregroundStyle(CBColor.gray9)
                .padding(.top, CBSpacing.large)

            Spacer(minLength: CBSpacing.large)

            Image(.onboarding4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 350)

            Spacer(minLength: CBSpacing.large)

            CBButton("common.confirm", action: onConfirm)
        }
        .padding(.horizontal, CBSpacing.pageHorizontal)
        .padding(.top, CBSpacing.small)
        .padding(.bottom, CBSpacing.medium)
        .background(CBColor.gray1)
    }
}

#Preview {
    OnboardingCompleteView(onBack: {}, onConfirm: {})
        .environment(\.locale, Locale(identifier: "ko"))
}
