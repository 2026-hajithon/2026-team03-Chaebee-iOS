import Foundation

struct TripRegistrationDraft: Equatable {
    var countryCode: String?
    var cityCode: String?
    var departureDate: Date?
    var returnDate: Date?
    var plansToBuyESIM: Bool?
    var plansToUseCash: Bool?

    var isComplete: Bool {
        countryCode != nil
            && cityCode != nil
            && departureDate != nil
            && returnDate != nil
            && plansToBuyESIM != nil
            && plansToUseCash != nil
    }
}
