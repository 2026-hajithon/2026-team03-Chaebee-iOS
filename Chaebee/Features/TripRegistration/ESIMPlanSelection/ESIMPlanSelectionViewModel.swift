import Combine

@MainActor
final class ESIMPlanSelectionViewModel: ObservableObject {
    @Published var showsCashUsageSelection = false

    func proceed() {
        showsCashUsageSelection = true
    }
}
