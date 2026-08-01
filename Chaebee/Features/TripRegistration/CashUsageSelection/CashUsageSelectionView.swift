import SwiftUI

struct CashUsageSelectionView: View {
    @StateObject private var viewModel: CashUsageSelectionViewModel

    init(plansToBuyESIM: Bool) {
        _viewModel = StateObject(
            wrappedValue: CashUsageSelectionViewModel(
                plansToBuyESIM: plansToBuyESIM
            )
        )
    }

    var body: some View {
        TripBinaryQuestionLayout(
            step: "tripRegistration.step.final",
            title: "tripRegistration.cashUsage.title",
            onAnswer: viewModel.select
        ) {
            Image(.cash)
                .resizable()
                .scaledToFit()
                .frame(width: 208, height: 208)
                .accessibilityHidden(true)
        }
        .navigationDestination(item: $viewModel.options) { options in
            TripSummaryView(options: options)
        }
    }
}

#Preview {
    NavigationStack {
        CashUsageSelectionView(plansToBuyESIM: true)
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
