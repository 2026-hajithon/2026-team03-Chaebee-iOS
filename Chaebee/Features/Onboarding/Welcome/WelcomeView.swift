import SwiftUI

struct WelcomeView: View {
    let onLogin: () -> Void
    let onContinueAsGuest: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                welcomeTitle
                    .padding(.top, max(34, proxy.safeAreaInsets.top + 18))

                Spacer(minLength: CBSpacing.large)

                Image(.onboarding1)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: min(390, proxy.size.height * 0.47))

                Spacer(minLength: CBSpacing.large)

                loginButtons
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.bottom, CBSpacing.medium)
        }
        .background(CBColor.gray1)
    }

    private var welcomeTitle: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("onboarding.welcome.brand")
                .foregroundStyle(CBColor.blue5)
            Text("onboarding.welcome.title")
                .foregroundStyle(CBColor.gray9)
        }
        .cbTypography(.head5)
    }

    private var loginButtons: some View {
        VStack(spacing: CBSpacing.small) {
            Button(action: onLogin) {
                HStack(spacing: CBSpacing.small) {
                    Image(.googleLogin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("onboarding.login.google")
                        .cbTypography(.body3)
                        .foregroundStyle(CBColor.gray9)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white, in: RoundedRectangle(cornerRadius: CBRadius.small))
                .overlay {
                    RoundedRectangle(cornerRadius: CBRadius.small)
                        .stroke(CBColor.gray3, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Button(action: onLogin) {
                HStack(spacing: CBSpacing.small) {
                    Image(systemName: "apple.logo")
                    Text("onboarding.login.apple")
                }
                .cbTypography(.body3)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.black, in: RoundedRectangle(cornerRadius: CBRadius.small))
            }
            .buttonStyle(.plain)

            Button(action: onContinueAsGuest) {
                Text("onboarding.login.guest")
                    .cbTypography(.caption1)
                    .foregroundStyle(CBColor.gray5)
                    .underline()
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    WelcomeView(onLogin: {}, onContinueAsGuest: {})
        .environment(\.locale, Locale(identifier: "ko"))
}
