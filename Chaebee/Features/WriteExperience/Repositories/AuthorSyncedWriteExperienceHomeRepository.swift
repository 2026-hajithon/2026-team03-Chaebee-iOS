import Foundation

/// Keeps locally-authored discovery contents while reflecting the member name
/// returned by `/discoveries/me`.
struct AuthorSyncedWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    let localRepository: any WriteExperienceHomeRepository
    let apiClient: any APIClient

    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
        try await localRepository.fetchDiscoveries(sort: sort)
    }

    func registerDiscovery(
        request: WriteExperienceRequest
    ) async throws -> [TravelerDiscovery] {
        try await localRepository.registerDiscovery(request: request)
    }

    func fetchMyDiscoveries() async throws -> [TravelerDiscovery] {
        let localDiscoveries = try await localRepository.fetchMyDiscoveries()

        guard !localDiscoveries.isEmpty,
              let authorName = await fetchAuthorName() else {
            return localDiscoveries
        }

        return localDiscoveries.map { discovery in
            TravelerDiscovery(
                id: discovery.id,
                authorName: authorName,
                authorAvatar: discovery.authorAvatar,
                createdAt: discovery.createdAt,
                content: discovery.content,
                country: discovery.country,
                tag: discovery.tag
            )
        }
    }

    private func fetchAuthorName() async -> String? {
        do {
            let response: APIResponseDTO<[DiscoveryListItemResponseDTO]> = try await apiClient.request(
                DiscoveryEndpoint.mine,
                as: APIResponseDTO<[DiscoveryListItemResponseDTO]>.self
            )
            return response.data
                .lazy
                .map(\.authorName)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty }
        } catch {
            return nil
        }
    }
}
