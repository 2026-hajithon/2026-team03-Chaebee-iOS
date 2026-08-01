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
        guard !query.isEmpty else { return locations }

        return locations.filter {
            $0.cityName.localizedCaseInsensitiveContains(query)
                || $0.country.searchAliases.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }
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
        case .us: ["미국", "United States", "USA"]
        case .vn: ["베트남", "Vietnam"]
        }
    }
}
