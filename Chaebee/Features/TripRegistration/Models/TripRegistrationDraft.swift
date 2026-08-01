import Foundation

struct TripRegistrationDraft: Equatable {
    var countryCode: String?
    var cityID: String?
    var departureDate: Date?
    var returnDate: Date?
    var plansToBuyESIM: Bool?
    var plansToUseCash: Bool?

    var isComplete: Bool {
        countryCode != nil
            && departureDate != nil
            && returnDate != nil
            && plansToBuyESIM != nil
            && plansToUseCash != nil
    }
}
