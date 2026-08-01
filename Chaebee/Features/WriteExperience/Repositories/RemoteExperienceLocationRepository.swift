import Foundation

struct RemoteExperienceLocationRepository: ExperienceLocationRepository {
    let apiClient: any APIClient
    private let fallbackRepository: any ExperienceLocationRepository

    init(
        apiClient: any APIClient,
        fallbackRepository: any ExperienceLocationRepository = FixtureExperienceLocationRepository()
    ) {
        self.apiClient = apiClient
        self.fallbackRepository = fallbackRepository
    }

    func searchLocations(query: String) async throws -> [ExperienceLocation] {
        let fallbackLocations = try await fallbackRepository.searchLocations(
            query: query
        )

        do {
            let response: APIResponseDTO<[TripRegistrationResponseDTO]> = try await apiClient.request(
                HomeTripListEndpoint(),
                as: APIResponseDTO<[TripRegistrationResponseDTO]>.self
            )
            let remoteLocations = response.data
                .compactMap(makeLocation)
                .filter { matches($0, query: query) }

            return merged(
                remoteLocations: remoteLocations,
                fallbackLocations: fallbackLocations
            )
        } catch {
#if DEBUG
            print("[ExperienceLocation] Using mock fallback: \(error.localizedDescription)")
#endif
            return fallbackLocations
        }
    }

    private func merged(
        remoteLocations: [ExperienceLocation],
        fallbackLocations: [ExperienceLocation]
    ) -> [ExperienceLocation] {
        var seenKeys = Set(remoteLocations.map(locationKey))
        let uniqueFallbacks = fallbackLocations.filter {
            seenKeys.insert(locationKey($0)).inserted
        }
        return remoteLocations + uniqueFallbacks
    }

    private func locationKey(_ location: ExperienceLocation) -> String {
        location.country.rawValue + "|" + location.cityName.lowercased()
    }

    private func matches(_ location: ExperienceLocation, query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return true }

        return location.cityName.localizedCaseInsensitiveContains(normalizedQuery)
                || String(localized: location.country.localizedName)
                    .localizedCaseInsensitiveContains(normalizedQuery)
    }

    private func makeLocation(
        from trip: TripRegistrationResponseDTO
    ) -> ExperienceLocation? {
        guard let country = ExperienceCountry(backendCode: trip.countryCode) else {
            return nil
        }

        return ExperienceLocation(
            id: trip.tripID,
            cityName: cityName(for: trip.cityCode),
            country: country
        )
    }

    private func cityName(for code: String) -> String {
        switch code {
        case "LOS_ANGELES": String(localized: "city.losAngeles")
        case "NEW_YORK": String(localized: "city.newYork")
        case "HONOLULU": String(localized: "city.honolulu")
        case "TAIPEI": "Taipei"
        case "SINGAPORE_CITY": "Singapore"
        case "TOKYO": "Tokyo"
        default: code.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
