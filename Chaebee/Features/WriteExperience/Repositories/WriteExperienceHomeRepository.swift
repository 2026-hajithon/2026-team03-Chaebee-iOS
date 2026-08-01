protocol WriteExperienceHomeRepository: Sendable {
    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery]
}
