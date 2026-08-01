import Foundation

struct PreparationTimeline: Equatable, Identifiable, Sendable {
    let id: Int
    let destinationName: String
    let countryCode: String
    let dDay: Int
    var progress: TimelineProgress
    let highlight: TimelineHighlight
    var phases: [TimelinePhase]
    let essentialInfo: TimelineEssentialInfo
}

struct TimelineProgress: Equatable, Sendable {
    var done: Int
    let total: Int

    var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(done) / Double(total) * 100).rounded())
    }
}

struct TimelineHighlight: Equatable, Sendable {
    let tag: PreparationTag
    let title: String
    let subtitle: String
}

struct TimelinePhase: Equatable, Identifiable, Sendable {
    let id: String
    let label: String
    let date: Date
    let isCurrent: Bool
    let discoveries: [TimelineDiscovery]
    var checklistItems: [TimelineChecklistItem]
}

struct TimelineDiscovery: Equatable, Identifiable, Sendable {
    let id: Int
    let tag: PreparationTag
    let content: String
}

struct TimelineChecklistItem: Equatable, Identifiable, Sendable {
    let id: Int
    let tag: PreparationTag
    let title: String
    var isChecked: Bool
    let actionTitle: String?
    let actionURL: URL?
}

struct TimelineEssentialInfo: Equatable, Sendable {
    let passportValidityRule: String
    let visaFreeStayDescription: String
    let officialSiteName: String
    let officialSiteURL: URL
    let lastUpdatedDescription: String
}

enum PreparationTag: String, Codable, Equatable, Sendable {
    case passport = "PASSPORT"
    case visa = "VISA"
    case vaccination = "VACCINATION"
    case insurance = "INSURANCE"
    case exchange = "EXCHANGE"
    case transitCard = "TRANSIT_CARD"
    case adapter = "ADAPTER"
    case esimRoaming = "ESIM_ROAMING"
    case entryForm = "ENTRY_FORM"
    case flightBoarding = "FLIGHT_BOARDING"
    case localAirport = "LOCAL_AIRPORT"
    case accommodationCheckin = "ACCOMMODATION_CHECKIN"

    var localizedName: LocalizedStringResource {
        switch self {
        case .passport: "preparationTag.passport"
        case .visa: "preparationTag.visa"
        case .vaccination: "preparationTag.vaccination"
        case .insurance: "preparationTag.insurance"
        case .exchange: "preparationTag.exchange"
        case .transitCard: "preparationTag.transitCard"
        case .adapter: "preparationTag.adapter"
        case .esimRoaming: "preparationTag.esimRoaming"
        case .entryForm: "preparationTag.entryForm"
        case .flightBoarding: "preparationTag.flightBoarding"
        case .localAirport: "preparationTag.localAirport"
        case .accommodationCheckin: "preparationTag.accommodationCheckin"
        }
    }
}
