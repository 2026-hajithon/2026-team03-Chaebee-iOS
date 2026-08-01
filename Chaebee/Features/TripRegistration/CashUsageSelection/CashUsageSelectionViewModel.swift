import Combine

@MainActor
final class CashUsageSelectionViewModel: ObservableObject {
    @Published var showsSummary = false

    func proceed() {
        showsSummary = true
    }
}
