import Foundation

struct RemoteTripRegistrationRepository: TripRegistrationRepository {
    let apiClient: any APIClient

    func createTrip(_ request: TripRegistrationRequest) async throws -> RegisteredTrip {
        let response: APIResponseDTO<TripRegistrationResponseDTO> = try await apiClient.request(
            try TripRegistrationEndpoint(request: request),
            as: APIResponseDTO<TripRegistrationResponseDTO>.self
        )

        guard
            let departureAt = TripRegistrationDateCodec.date(from: response.data.departureAt),
            let arrivalAt = TripRegistrationDateCodec.date(from: response.data.arrivalAt)
        else {
            throw TripRegistrationRepositoryError.invalidDate
        }

        return RegisteredTrip(
            id: response.data.tripID,
            countryCode: response.data.countryCode,
            cityCode: response.data.cityCode,
            departureAt: departureAt,
            arrivalAt: arrivalAt,
            esimPlan: response.data.esimPlan,
            cashPlan: response.data.cashPlan,
            dDay: response.data.dDay
        )
    }
}

enum TripRegistrationRepositoryError: Error {
    case invalidDate
    case unavailable
}
