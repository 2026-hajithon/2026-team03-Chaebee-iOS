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

    func deleteTrip(id: Int) async {
        guard var updatedDashboard = dashboard else { return }
        let previousDashboard = updatedDashboard
        updatedDashboard = HomeDashboard(
            trips: updatedDashboard.trips.filter { $0.id != id },
            editorDiscoveries: updatedDashboard.editorDiscoveries
        )
        dashboard = updatedDashboard

        do {
            try await repository.deleteTrip(id: id)
        } catch {
            dashboard = previousDashboard
            errorMessage = error.localizedDescription
        }
    }
}
