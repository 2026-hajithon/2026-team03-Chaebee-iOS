import Combine
import Foundation

@MainActor
final class WriteExperienceHomeViewModel: ObservableObject {
    @Published private(set) var discoveries: [TravelerDiscovery] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any WriteExperienceHomeRepository
    private let sort: ExperienceFeedSort = .latest
    private var nextLocalDiscoveryID = -1

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

    func register(_ request: WriteExperienceRequest) {
        guard let country = ExperienceCountry(rawValue: request.countryCode) else {
            return
        }

        let createdAt = Date.now
        let newDiscoveries = request.discoveries.map { discovery in
            defer { nextLocalDiscoveryID -= 1 }

            return TravelerDiscovery(
                id: nextLocalDiscoveryID,
                authorName: String(localized: "writeExperience.feed.currentUser"),
                authorAvatar: .blue,
                createdAt: createdAt,
                content: discovery.content,
                country: country,
                tag: discovery.tag
            )
        }

        discoveries.insert(contentsOf: newDiscoveries, at: 0)
    }
}
