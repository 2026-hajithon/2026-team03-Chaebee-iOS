import Foundation

struct WriteExperienceDraft: Equatable, Sendable {
    var location: ExperienceLocation?
    var travelType: ExperienceTravelType?
    var discoveries: [ExperienceDraftDiscovery] = []

    var canProceed: Bool {
        location != nil && travelType != nil && !discoveries.isEmpty
    }
}

struct ExperienceLocation: Equatable, Identifiable, Sendable {
    let id: Int
    let cityName: String
    let country: ExperienceCountry
}

enum ExperienceTravelType: String, CaseIterable, Codable, Identifiable, Sendable {
    case solo = "SOLO"
    case friends = "FRIEND"
    case couple = "COUPLE"
    case family = "FAMILY"
    case group = "GROUP"
    case withPet = "WITH_PET"

    var id: String { rawValue }

    var localizedName: LocalizedStringResource {
        switch self {
        case .solo: "writeExperience.travelType.solo"
        case .friends: "writeExperience.travelType.friends"
        case .couple: "writeExperience.travelType.couple"
        case .family: "writeExperience.travelType.family"
        case .group: "writeExperience.travelType.group"
        case .withPet: "writeExperience.travelType.withPet"
        }
    }
}

struct ExperienceDraftDiscovery: Equatable, Identifiable, Sendable {
    let id: UUID
    let tag: PreparationTag
    let content: String

    init(id: UUID = UUID(), tag: PreparationTag, content: String) {
        self.id = id
        self.tag = tag
        self.content = content
    }
}

final class WriteExperienceRequest: Sendable {
    let tripID: Int
    let country: ExperienceCountry
    let travelType: ExperienceTravelType
    let discoveries: [DiscoveryRequest]

    struct DiscoveryRequest: Sendable {
        let tag: PreparationTag
        let content: String
    }

    var countryCode: String { country.rawValue }

    init?(draft: WriteExperienceDraft) {
        guard let location = draft.location,
              let travelType = draft.travelType,
              !draft.discoveries.isEmpty else {
            return nil
        }

        tripID = location.id
        country = location.country
        self.travelType = travelType
        discoveries = draft.discoveries.map {
            DiscoveryRequest(tag: $0.tag, content: $0.content)
        }
    }
}
