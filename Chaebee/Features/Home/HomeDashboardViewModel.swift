import Combine
import Foundation

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    @Published private(set) var dashboard: HomeDashboard?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any HomeDashboardRepository

    init(repository: any HomeDashboardRepository) {
        self.repository = repository
    }

    func load() async {
        guard dashboard == nil, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            dashboard = try await repository.fetchDashboard()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retry() async {
        dashboard = nil
        await load()
    }
}
