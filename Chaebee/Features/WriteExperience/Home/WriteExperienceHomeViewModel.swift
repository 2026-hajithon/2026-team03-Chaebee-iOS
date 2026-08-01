import Combine
import Foundation

@MainActor
final class WriteExperienceHomeViewModel: ObservableObject {
    @Published private(set) var discoveries: [TravelerDiscovery] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any WriteExperienceHomeRepository
    private let sort: ExperienceFeedSort = .latest

    init(repository: any WriteExperienceHomeRepository) {
        self.repository = repository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            discoveries = try await repository.fetchDiscoveries(sort: sort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retry() async {
        discoveries = []
        await load()
    }
}
