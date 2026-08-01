import SwiftUI

struct PassportGuideView: View {
    let onBack: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingNavigationHeader(currentStep: 2, totalSteps: 2, onBack: onBack)

            VStack(alignment: .leading, spacing: CBSpacing.small) {
                Text("onboarding.multipleNationality.title")
                    .cbTypography(.head4)
                    .foregroundStyle(CBColor.gray9)
                Text("onboarding.multipleNationality.subtitle")
                    .cbTypography(.body3)
                    .foregroundStyle(CBColor.gray5)
            }
            .padding(.top, CBSpacing.large)

            Spacer(minLength: CBSpacing.large)

            Image(.onboarding3)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 390)

            Spacer(minLength: CBSpacing.large)

            OnboardingChoiceButton(
                title: "onboarding.multipleNationality.confirm",
                variant: .primary,
                symbol: .confirm,
                action: onConfirm
            )
        }
        .padding(.horizontal, CBSpacing.pageHorizontal)
        .padding(.top, CBSpacing.small)
        .padding(.bottom, CBSpacing.medium)
        .background(CBColor.gray1)
    }
}

#Preview {
    PassportGuideView(onBack: {}, onConfirm: {})
        .environment(\.locale, Locale(identifier: "ko"))
}
