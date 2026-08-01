import SwiftUI

struct ESIMPlanSelectionView: View {
    @StateObject private var viewModel = ESIMPlanSelectionViewModel()

    var body: some View {
        TripBinaryQuestionLayout(
            step: "tripRegistration.step.fourOfFive",
            title: "tripRegistration.esimPlan.title",
            onAnswer: viewModel.select
        ) {
            Image(.simCard)
                .resizable()
                .scaledToFit()
                .frame(width: 184, height: 184)
                .accessibilityHidden(true)
        }
        .navigationDestination(isPresented: $viewModel.showsCashUsageSelection) {
            CashUsageSelectionView(plansToBuyESIM: viewModel.plansToBuyESIM)
        }
    }
}

#Preview {
    NavigationStack {
        ESIMPlanSelectionView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
