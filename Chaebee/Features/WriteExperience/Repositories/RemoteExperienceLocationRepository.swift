import Foundation

struct RemoteExperienceLocationRepository: ExperienceLocationRepository {
    let apiClient: any APIClient

    func searchLocations(query: String) async throws -> [ExperienceLocation] {
        let response: APIResponseDTO<[TripRegistrationResponseDTO]> = try await apiClient.request(
            HomeTripListEndpoint(),
            as: APIResponseDTO<[TripRegistrationResponseDTO]>.self
        )
        let locations = response.data.compactMap(makeLocation)
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return locations }

        return locations.filter { location in
            location.cityName.localizedCaseInsensitiveContains(normalizedQuery)
                || String(localized: location.country.localizedName)
                    .localizedCaseInsensitiveContains(normalizedQuery)
        }
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
