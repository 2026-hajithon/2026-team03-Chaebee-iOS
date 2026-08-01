import Combine

@MainActor
final class CashUsageSelectionViewModel: ObservableObject {
    @Published var options: TripRegistrationOptions?

    private let plansToBuyESIM: Bool

    init(plansToBuyESIM: Bool) {
        self.plansToBuyESIM = plansToBuyESIM
    }

    func select(_ answer: Bool) {
        options = TripRegistrationOptions(
            plansToBuyESIM: plansToBuyESIM,
            plansToUseCash: answer
        )
    }
}
