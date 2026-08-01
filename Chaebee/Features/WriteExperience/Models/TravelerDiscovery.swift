import Foundation

struct TravelerDiscovery: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let authorName: String
    let authorAvatar: ExperienceAvatar
    let createdAt: Date
    let content: String
    let country: ExperienceCountry
    let tag: PreparationTag
}

enum ExperienceAvatar: String, Codable, Equatable, Sendable {
    case blue
    case green
    case indigo
    case orange
    case red
    case yellow
}

enum ExperienceCountry: String, Codable, CaseIterable, Equatable, Sendable {
    case au = "AU"
    case br = "BR"
    case de = "DE"
    case fr = "FR"
    case hk = "HK"
    case jp = "JP"
    case sg = "SG"
    case th = "TH"
    case tw = "TW"
    case uk = "GB"
    case us = "US"
    case vn = "VN"
}

enum ExperienceFeedSort: String, Codable, Equatable, Sendable {
    case latest = "LATEST"
}
