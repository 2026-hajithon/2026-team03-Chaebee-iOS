import SwiftUI

struct PassportSelectionView: View {
    @State private var isInfoPresented = false

    let onBack: () -> Void
    let onKoreanPassportSelected: () -> Void
    let onUnsupportedSelected: () -> Void

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                OnboardingNavigationHeader(currentStep: 1, totalSteps: 2, onBack: onBack)

                VStack(alignment: .leading, spacing: CBSpacing.small) {
                    Text("onboarding.passport.title")
                        .cbTypography(.head4)
                        .foregroundStyle(CBColor.gray9)
                    Text("onboarding.passport.subtitle")
                        .cbTypography(.body3)
                        .foregroundStyle(CBColor.gray5)
                }
                .padding(.top, CBSpacing.large)

                Spacer(minLength: CBSpacing.medium)

                Image(.onboarding2)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 360)

                Spacer(minLength: CBSpacing.medium)

                Button {
                    isInfoPresented = true
                } label: {
                    Text("onboarding.passport.whyNeeded")
                        .cbTypography(.caption1)
                        .foregroundStyle(CBColor.gray5)
                        .underline()
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
                .buttonStyle(.plain)
                .padding(.bottom, CBSpacing.medium)

                VStack(spacing: CBSpacing.small) {
                    OnboardingChoiceButton(
                        title: "onboarding.passport.no",
                        variant: .secondary,
                        symbol: .no,
                        action: onUnsupportedSelected
                    )
                    OnboardingChoiceButton(
                        title: "onboarding.passport.yes",
                        variant: .primary,
                        symbol: .yes,
                        action: onKoreanPassportSelected
                    )
                }
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.small)
            .padding(.bottom, CBSpacing.medium)

            if isInfoPresented {
                OnboardingInfoDialog {
                    withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
                        isInfoPresented = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(10)
            }
        }
        .background(CBColor.gray1)
        .animation(.easeOut(duration: CBAnimation.quickDuration), value: isInfoPresented)
    }
}

#Preview {
    PassportSelectionView(
        onBack: {},
        onKoreanPassportSelected: {},
        onUnsupportedSelected: {}
    )
    .environment(\.locale, Locale(identifier: "ko"))
}
