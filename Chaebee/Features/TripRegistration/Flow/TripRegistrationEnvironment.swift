import SwiftUI

private struct TripRegistrationRepositoryKey: EnvironmentKey {
    static let defaultValue: any TripRegistrationRepository = UnavailableTripRegistrationRepository()
}

extension EnvironmentValues {
    var tripRegistrationRepository: any TripRegistrationRepository {
        get { self[TripRegistrationRepositoryKey.self] }
        set { self[TripRegistrationRepositoryKey.self] = newValue }
    }
}

private struct UnavailableTripRegistrationRepository: TripRegistrationRepository {
    func createTrip(_ request: TripRegistrationRequest) async throws -> RegisteredTrip {
        throw TripRegistrationRepositoryError.unavailable
    }
}
