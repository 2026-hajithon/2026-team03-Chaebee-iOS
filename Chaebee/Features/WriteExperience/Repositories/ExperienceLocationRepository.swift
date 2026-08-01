protocol ExperienceLocationRepository: Sendable {
    func searchLocations(query: String) async throws -> [ExperienceLocation]
}
