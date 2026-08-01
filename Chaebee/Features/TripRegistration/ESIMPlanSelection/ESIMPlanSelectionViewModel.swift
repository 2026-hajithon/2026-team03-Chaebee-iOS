import Combine

@MainActor
final class ESIMPlanSelectionViewModel: ObservableObject {
    @Published private(set) var plansToBuyESIM = false
    @Published var showsCashUsageSelection = false

    func select(_ answer: Bool) {
        plansToBuyESIM = answer
        showsCashUsageSelection = true
    }
}
