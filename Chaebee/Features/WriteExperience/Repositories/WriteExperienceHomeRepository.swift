protocol WriteExperienceHomeRepository: Sendable {
    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery]

    func registerDiscovery(
        request: WriteExperienceRequest
    ) async throws -> [TravelerDiscovery]
}
