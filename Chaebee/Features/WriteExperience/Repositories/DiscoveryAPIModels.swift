import Foundation

struct DiscoveryRegistrationRequestDTO: Encodable {
    let tripID: Int
    let tripType: String
    let subDiscoveries: [SubDiscoveryRegistrationRequestDTO]

    private enum CodingKeys: String, CodingKey {
        case tripID = "tripId"
        case tripType
        case subDiscoveries
    }
}

struct SubDiscoveryRegistrationRequestDTO: Encodable {
    let tag: String
    let content: String
}

struct DiscoveryPageResponseDTO: Decodable {
    let content: [DiscoveryListItemResponseDTO]
    let totalElements: Int
    let totalPages: Int
    let currentPage: Int
}

struct DiscoveryListItemResponseDTO: Decodable {
    let discoveryID: Int
    let countryCode: String
    let cityCode: String
    let tripType: String
    let authorName: String
    let createdAt: String
    let subDiscoveries: [SubDiscoveryResponseDTO]?
    let tag: String?
    let content: String?

    private enum CodingKeys: String, CodingKey {
        case discoveryID = "discoveryId"
        case countryCode
        case cityCode
        case tripType
        case authorName
        case createdAt
        case subDiscoveries
        case tag
        case content
    }
}

struct DiscoveryRegistrationResponseDTO: Decodable {
    let discoveryID: Int
    let tripID: Int
    let countryCode: String
    let cityCode: String
    let tripType: String
    let createdAt: String
    let subDiscoveries: [SubDiscoveryResponseDTO]

    private enum CodingKeys: String, CodingKey {
        case discoveryID = "discoveryId"
        case tripID = "tripId"
        case countryCode
        case cityCode
        case tripType
        case createdAt
        case subDiscoveries
    }
}

struct SubDiscoveryResponseDTO: Decodable {
    let subDiscoveryID: Int
    let tag: String
    let content: String

    private enum CodingKeys: String, CodingKey {
        case subDiscoveryID = "subDiscoveryId"
        case tag
        case content
    }
}
