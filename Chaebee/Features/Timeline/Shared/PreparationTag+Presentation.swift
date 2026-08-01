import SwiftUI

extension PreparationTag {
    var iconResource: ImageResource {
        switch self {
        case .passport: .passport
        case .visa: .ticketVisa
        case .vaccination: .vaccination
        case .insurance: .insurance
        case .exchange: .currencyExchange
        case .transitCard: .creditCard
        case .adapter: .adapter
        case .esimRoaming: .simCard
        case .entryForm: .documentAndPen
        case .flightBoarding: .boardingPass
        case .localAirport: .destination
        case .accommodationCheckin: .accommodation
        }
    }
}
