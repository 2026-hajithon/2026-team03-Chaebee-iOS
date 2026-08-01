import Foundation

struct FixtureExperienceLocationRepository: ExperienceLocationRepository {
    private let locations = [
        ExperienceLocation(id: 101, cityName: "로스앤젤레스", country: .us),
        ExperienceLocation(id: 102, cityName: "뉴욕", country: .us),
        ExperienceLocation(id: 201, cityName: "타이베이", country: .tw),
        ExperienceLocation(id: 301, cityName: "싱가포르", country: .sg),
        ExperienceLocation(id: 401, cityName: "도쿄", country: .jp)
    ]

    func searchLocations(query: String) async throws -> [ExperienceLocation] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return locations }

        return locations.filter {
            $0.citySearchAliases.contains {
                $0.localizedCaseInsensitiveContains(normalizedQuery)
            }
                || $0.country.searchAliases.contains {
                    $0.localizedCaseInsensitiveContains(normalizedQuery)
                }
        }
    }
}

private extension ExperienceLocation {
    var citySearchAliases: [String] {
        switch id {
        case 101: [cityName, "Los Angeles", "LA", "LAX"]
        case 102: [cityName, "New York", "NY", "NYC"]
        case 201: [cityName, "Taipei"]
        case 301: [cityName, "Singapore"]
        case 401: [cityName, "Tokyo"]
        default: [cityName]
        }
    }
}

private extension ExperienceCountry {
    var searchAliases: [String] {
        switch self {
        case .au: ["호주", "Australia"]
        case .br: ["브라질", "Brazil"]
        case .de: ["독일", "Germany"]
        case .fr: ["프랑스", "France"]
        case .hk: ["홍콩", "Hong Kong"]
        case .jp: ["일본", "Japan"]
        case .sg: ["싱가포르", "Singapore"]
        case .th: ["태국", "Thailand"]
        case .tw: ["대만", "Taiwan"]
        case .uk: ["영국", "United Kingdom"]
        case .us: ["미국", "United States", "USA", "US"]
        case .vn: ["베트남", "Vietnam"]
        }
    }
}
