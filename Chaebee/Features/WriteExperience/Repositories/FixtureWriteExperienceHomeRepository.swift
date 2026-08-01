import Foundation

@MainActor
final class FixtureWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    enum State: Equatable, Sendable {
        case populated
        case empty
    }

    private var discoveries: [TravelerDiscovery]
    private let localStore: LocalDiscoveryStoring
    private let profileRepository: ProfileRepository

    init(
        state: State = .empty,
        localStore: LocalDiscoveryStoring? = nil,
        profileRepository: ProfileRepository? = nil
    ) {
        let resolvedStore = localStore ?? UserDefaultsLocalDiscoveryStore()
        self.localStore = resolvedStore
        self.profileRepository = profileRepository ?? LocalProfileRepository()

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
        let profile = profileRepository.fetchProfile()
        let newDiscoveries = request.discoveries.map { discovery in
            return TravelerDiscovery(
                id: localStore.nextDiscoveryID(),
                authorName: profile.nickname,
                authorAvatar: profile.avatarColor,
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
