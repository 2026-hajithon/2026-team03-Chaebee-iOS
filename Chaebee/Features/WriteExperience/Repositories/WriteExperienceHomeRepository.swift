@MainActor
protocol WriteExperienceHomeRepository {
    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery]

    func registerDiscovery(
        request: WriteExperienceRequest
    ) -> [TravelerDiscovery]
}
