import SwiftUI

struct ESIMPlanSelectionView: View {
    @ObservedObject private var registration: TripRegistrationViewModel
    @StateObject private var viewModel = ESIMPlanSelectionViewModel()

    init(registration: TripRegistrationViewModel) {
        self.registration = registration
    }

    var body: some View {
        TripBinaryQuestionLayout(
            step: "tripRegistration.step.fourOfFive",
            title: "tripRegistration.esimPlan.title",
            onAnswer: select
        ) {
            Image(.simCard)
                .resizable()
                .scaledToFit()
                .frame(width: 184, height: 184)
                .accessibilityHidden(true)
        }
        .navigationDestination(isPresented: $viewModel.showsCashUsageSelection) {
            CashUsageSelectionView(registration: registration)
        }
    }

    private func select(_ answer: Bool) {
        registration.setPlansToBuyESIM(answer)
        viewModel.proceed()
    }
}

#Preview {
    NavigationStack {
        ESIMPlanSelectionView(registration: TripRegistrationViewModel())
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
