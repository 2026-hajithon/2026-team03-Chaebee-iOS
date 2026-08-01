import SwiftUI

struct CashUsageSelectionView: View {
    @Environment(\.tripRegistrationRepository) private var repository
    @ObservedObject private var registration: TripRegistrationViewModel

    init(registration: TripRegistrationViewModel) {
        self.registration = registration
    }

    var body: some View {
        TripBinaryQuestionLayout(
            step: "tripRegistration.step.final",
            title: "tripRegistration.cashUsage.title",
            onAnswer: select
        ) {
            Image(.cash)
                .resizable()
                .scaledToFit()
                .frame(width: 208, height: 208)
                .accessibilityHidden(true)
        }
        .allowsHitTesting(!registration.isSubmitting)
        .overlay {
            if registration.isSubmitting {
                ProgressView()
                    .tint(CBColor.blue5)
                    .padding(CBSpacing.medium)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .overlay(alignment: .bottom) {
            if let message = registration.submissionErrorMessage {
                errorToast(message)
                    .padding(.horizontal, CBSpacing.pageHorizontal)
                    .padding(.bottom, 128)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: CBAnimation.quickDuration), value: registration.submissionErrorMessage)
    }

    private func select(_ answer: Bool) {
        registration.setPlansToUseCash(answer)
        Task {
            await registration.submit(using: repository)
        }
    }

    private func errorToast(_ message: String) -> some View {
        HStack(spacing: CBSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(CBColor.yellow)

            Text(verbatim: message)
                .cbTypography(.body4)
                .foregroundStyle(Color.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, CBSpacing.medium)
        .frame(minHeight: 56)
        .background(CBColor.gray5)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
    }
}

#Preview {
    NavigationStack {
        CashUsageSelectionView(registration: TripRegistrationViewModel())
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
