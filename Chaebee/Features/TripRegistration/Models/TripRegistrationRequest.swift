import Foundation

struct TripRegistrationRequest: Equatable, Sendable {
    let countryCode: String
    let cityCode: String
    let departureAt: Date
    let arrivalAt: Date
    let esimPlan: Bool
    let cashPlan: Bool

    init(draft: TripRegistrationDraft) throws {
        guard
            let countryCode = draft.countryCode,
            let cityCode = draft.cityCode,
            let departureDate = draft.departureDate,
            let returnDate = draft.returnDate,
            let plansToBuyESIM = draft.plansToBuyESIM,
            let plansToUseCash = draft.plansToUseCash
        else {
            throw TripRegistrationValidationError.incompleteDraft
        }

        guard returnDate >= departureDate else {
            throw TripRegistrationValidationError.invalidDateRange
        }

        self.countryCode = countryCode
        self.cityCode = cityCode
        self.departureAt = departureDate
        self.arrivalAt = returnDate
        self.esimPlan = plansToBuyESIM
        self.cashPlan = plansToUseCash
    }
}

struct RegisteredTrip: Equatable, Sendable {
    let id: Int
    let countryCode: String
    let cityCode: String
    let departureAt: Date
    let arrivalAt: Date
    let esimPlan: Bool
    let cashPlan: Bool
    let dDay: Int
}

enum TripRegistrationValidationError: Error, Equatable {
    case incompleteDraft
    case invalidDateRange
}

protocol TripRegistrationRepository: Sendable {
    func createTrip(_ request: TripRegistrationRequest) async throws -> RegisteredTrip
}
