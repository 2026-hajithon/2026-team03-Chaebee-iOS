import Foundation

struct TimelineResponseDTO: Decodable {
    let tripInfo: TimelineTripInfoDTO
    let timeline: [TimelinePhaseDTO]
    let essentialInfo: EssentialInfoResponseDTO
}

struct TimelineTripInfoDTO: Decodable {
    let destination: String
    let dDay: Int
    let progress: TimelineProgressDTO
}

struct TimelineProgressDTO: Decodable {
    let total: Int
    let completed: Int
    let percentage: Int
}

struct TimelinePhaseDTO: Decodable {
    let dDay: Int
    let date: String
    let discoveries: [TimelineDiscoveryDTO]
    let checklists: [TimelineChecklistItemDTO]
}

struct TimelineChecklistItemDTO: Decodable {
    let checklistID: Int
    let tag: PreparationTag
    let title: String
    let isChecked: Bool

    private enum CodingKeys: String, CodingKey {
        case checklistID = "checklistId"
        case tag
        case title
        case isChecked
    }
}

struct TimelineDiscoveryDTO: Decodable {
    let tag: PreparationTag
    let title: String
    let content: String
}

struct EssentialInfoResponseDTO: Decodable {
    let passportValidityRule: String
    let visaFreeStayDays: Int
    let officialSiteURL: URL
    let lastUpdatedAt: String

    private enum CodingKeys: String, CodingKey {
        case passportValidityRule
        case visaFreeStayDays
        case officialSiteURL = "officialSiteUrl"
        case lastUpdatedAt
    }
}

struct ChecklistUpdateRequestDTO: Encodable, Sendable {
    let isChecked: Bool
}
