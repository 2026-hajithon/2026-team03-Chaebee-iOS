import Foundation

struct TimelineResponseDTO: Decodable {
    let tripID: Int
    let progress: TimelineProgressDTO
    let phases: [TimelinePhaseDTO]

    private enum CodingKeys: String, CodingKey {
        case tripID = "tripId"
        case progress
        case phases
    }
}

struct TimelineProgressDTO: Decodable {
    let done: Int
    let total: Int
    let percent: Int
}

struct TimelinePhaseDTO: Decodable {
    let phaseLabel: String
    let checklistItems: [TimelineChecklistItemDTO]
    let subDiscoveries: [TimelineSubDiscoveryDTO]
}

struct TimelineChecklistItemDTO: Decodable {
    let checklistItemID: Int
    let tag: PreparationTag
    let title: String
    let isChecked: Bool

    private enum CodingKeys: String, CodingKey {
        case checklistItemID = "checklistItemId"
        case tag
        case title
        case isChecked
    }
}

struct TimelineSubDiscoveryDTO: Decodable {
    let subDiscoveryID: Int
    let tag: PreparationTag
    let content: String

    private enum CodingKeys: String, CodingKey {
        case subDiscoveryID = "subDiscoveryId"
        case tag
        case content
    }
}

struct EssentialInfoResponseDTO: Decodable {
    let countryCode: String
    let passportValidityRule: String
    let visaFreeStayDays: Int
    let officialSiteURL: URL
    let lastUpdatedAt: String

    private enum CodingKeys: String, CodingKey {
        case countryCode
        case passportValidityRule
        case visaFreeStayDays
        case officialSiteURL = "officialSiteUrl"
        case lastUpdatedAt
    }
}

struct ChecklistUpdateRequestDTO: Encodable, Sendable {
    let isChecked: Bool
}
