import Foundation

struct TripRegistrationRequest: Encodable, Equatable {
    let countryCode: String
    let cityID: String?
    let departureDate: Date
    let returnDate: Date
    let plansToBuyESIM: Bool
    let plansToUseCash: Bool

    init(draft: TripRegistrationDraft) throws {
        guard
            let countryCode = draft.countryCode,
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
        self.cityID = draft.cityID
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.plansToBuyESIM = plansToBuyESIM
        self.plansToUseCash = plansToUseCash
    }
}

enum TripRegistrationValidationError: Error, Equatable {
    case incompleteDraft
    case invalidDateRange
}

protocol TripRegistrationRepository {
    func createTrip(_ request: TripRegistrationRequest) async throws
}
