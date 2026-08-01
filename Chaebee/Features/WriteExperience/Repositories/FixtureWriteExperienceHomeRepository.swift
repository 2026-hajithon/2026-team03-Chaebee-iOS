import Foundation

@MainActor
final class FixtureWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    enum State: Equatable, Sendable {
        case populated
        case empty
    }

    private var discoveries: [TravelerDiscovery]
    private let localStore: LocalDiscoveryStoring

    init(
        state: State = .populated,
        localStore: LocalDiscoveryStoring? = nil
    ) {
        let resolvedStore = localStore ?? UserDefaultsLocalDiscoveryStore()
        self.localStore = resolvedStore

        discoveries = state == .populated
            ? resolvedStore.fetchDiscoveries()
            : []
    }

    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
        discoveries
    }

    func registerDiscovery(
        request: WriteExperienceRequest
    ) async throws -> [TravelerDiscovery] {
        let createdAt = Date.now
        let newDiscoveries = request.discoveries.map { discovery in
            return TravelerDiscovery(
                id: localStore.nextDiscoveryID(),
                authorName: String(localized: "writeExperience.feed.currentUser"),
                authorAvatar: .blue,
                createdAt: createdAt,
                content: discovery.content,
                country: request.country,
                tag: discovery.tag
            )
        }

        localStore.prependDiscoveries(newDiscoveries)
        discoveries.insert(contentsOf: newDiscoveries, at: 0)
        return newDiscoveries
    }

    func fetchMyDiscoveries() async throws -> [TravelerDiscovery] {
        localStore.fetchDiscoveries()
    }
}
