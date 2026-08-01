import SwiftUI

struct CashUsageSelectionView: View {
    @ObservedObject private var registration: TripRegistrationViewModel
    @StateObject private var viewModel = CashUsageSelectionViewModel()

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
        .navigationDestination(isPresented: $viewModel.showsSummary) {
            TripSummaryView(registration: registration)
        }
    }

    private func select(_ answer: Bool) {
        registration.setPlansToUseCash(answer)
        viewModel.proceed()
    }
}

#Preview {
    NavigationStack {
        CashUsageSelectionView(registration: TripRegistrationViewModel())
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
