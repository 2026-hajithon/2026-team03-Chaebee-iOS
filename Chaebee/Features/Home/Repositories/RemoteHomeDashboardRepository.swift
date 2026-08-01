import Foundation

struct RemoteHomeDashboardRepository: HomeDashboardRepository {
    let apiClient: any APIClient

    func fetchDashboard() async throws -> HomeDashboard {
        let response: APIResponseDTO<[TripRegistrationResponseDTO]>

        do {
            response = try await apiClient.request(
                HomeTripListEndpoint(),
                as: APIResponseDTO<[TripRegistrationResponseDTO]>.self
            )
        } catch let error as APIError where isMissingTrip(error) {
            return emptyDashboard
        }

        return HomeDashboard(
            trips: response.data.map(makeTripSummary),
            editorDiscoveries: []
        )
    }

    private var emptyDashboard: HomeDashboard {
        HomeDashboard(
            trips: [],
            editorDiscoveries: []
        )
    }

    private func isMissingTrip(_ error: APIError) -> Bool {
        switch error {
        case let .server(status, code, message):
            if status == 404 {
                return code == nil || code == "TRIP_NOT_FOUND"
            }

            return status == 400
                && code == "BAD_REQUEST"
                && message.contains("TRIP_NOT_FOUND")
        case .invalidStatusCode(404):
            return true
        default:
            return false
        }
    }

    func deleteTrip(id: Int) async throws {
        let _: APIResponseDTO<String> = try await apiClient.request(
            TripDeletionEndpoint(tripID: id),
            as: APIResponseDTO<String>.self
        )
    }

    private func makeTripSummary(
        from trip: TripRegistrationResponseDTO
    ) -> HomeTripSummary {
        HomeTripSummary(
            id: trip.tripID,
            destinationName: tripTitle(countryCode: trip.countryCode, cityCode: trip.cityCode),
            countryCode: trip.countryCode,
            flagAssetName: flagAssetName(for: trip.countryCode),
            dDay: trip.dDay,
            completedCount: 0,
            totalCount: 0,
            timelineDestination: timelineDestination(
                countryCode: trip.countryCode,
                cityCode: trip.cityCode
            )
        )
    }

    private func tripTitle(countryCode: String, cityCode: String) -> String {
        let destination: String

        switch (countryCode, cityCode) {
        case ("USA", "LOS_ANGELES"):
            destination = String(localized: "city.losAngeles")
        case ("USA", "NEW_YORK"):
            destination = String(localized: "city.newYork")
        case ("TAIWAN", _):
            destination = String(localized: "country.tw")
        case ("SINGAPORE", _):
            destination = String(localized: "country.sg")
        default:
            destination = countryCode
        }

        return String(
            format: String(localized: "home.trip.titleFormat"),
            destination
        )
    }

    private func flagAssetName(for countryCode: String) -> String {
        switch countryCode {
        case "USA": "flagUS"
        case "TAIWAN": "flagTW"
        case "SINGAPORE": "flagSG"
        case "JAPAN": "flagJP"
        case "BRAZIL": "flagBR"
        case "AUSTRALIA": "flagAU"
        case "THAILAND": "flagTH"
        case "VIETNAM": "flagVN"
        case "HONGKONG": "flagHK"
        case "FRANCE": "flagFR"
        default: "flagUS"
        }
    }

    private func timelineDestination(
        countryCode: String,
        cityCode: String
    ) -> FixturePreparationTimelineRepository.Destination {
        switch (countryCode, cityCode) {
        case ("USA", "LOS_ANGELES"):
            .losAngeles
        case ("USA", "NEW_YORK"):
            .newYork
        case ("TAIWAN", _):
            .taiwan
        case ("SINGAPORE", _):
            .singapore
        default:
            .singapore
        }
    }
}
