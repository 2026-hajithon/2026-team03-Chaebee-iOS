import Foundation

struct RemoteWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    let apiClient: any APIClient

    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
        let response: APIResponseDTO<DiscoveryPageResponseDTO> = try await apiClient.request(
            DiscoveryEndpoint.list(),
            as: APIResponseDTO<DiscoveryPageResponseDTO>.self
        )
        return response.data.content.flatMap {
            map($0, isCurrentUser: false)
        }
    }

    func registerDiscovery(
        request: WriteExperienceRequest
    ) async throws -> [TravelerDiscovery] {
        let response: APIResponseDTO<DiscoveryRegistrationResponseDTO> = try await apiClient.request(
            try DiscoveryEndpoint.register(request: request),
            as: APIResponseDTO<DiscoveryRegistrationResponseDTO>.self
        )
        return map(response.data)
    }

    func fetchMyDiscoveries() async throws -> [TravelerDiscovery] {
        let response: APIResponseDTO<[DiscoveryListItemResponseDTO]> = try await apiClient.request(
            DiscoveryEndpoint.mine,
            as: APIResponseDTO<[DiscoveryListItemResponseDTO]>.self
        )
        return response.data.flatMap {
            map($0, isCurrentUser: true)
        }
    }

    private func map(
        _ response: DiscoveryListItemResponseDTO,
        isCurrentUser: Bool
    ) -> [TravelerDiscovery] {
        guard let country = ExperienceCountry(backendCode: response.countryCode) else {
            return []
        }

        let subDiscoveries: [SubDiscoveryResponseDTO]
        if let values = response.subDiscoveries {
            subDiscoveries = values
        } else if let tag = response.tag, let content = response.content {
            subDiscoveries = [
                SubDiscoveryResponseDTO(
                    subDiscoveryID: response.discoveryID,
                    tag: tag,
                    content: content
                )
            ]
        } else {
            subDiscoveries = []
        }

        return subDiscoveries.compactMap { subDiscovery in
            makeTravelerDiscovery(
                id: subDiscovery.subDiscoveryID,
                authorName: response.authorName,
                createdAt: response.createdAt,
                country: country,
                tag: subDiscovery.tag,
                content: subDiscovery.content,
                isCurrentUser: isCurrentUser
            )
        }
    }

    private func map(
        _ response: DiscoveryRegistrationResponseDTO
    ) -> [TravelerDiscovery] {
        guard let country = ExperienceCountry(backendCode: response.countryCode) else {
            return []
        }

        return response.subDiscoveries.compactMap { subDiscovery in
            makeTravelerDiscovery(
                id: subDiscovery.subDiscoveryID,
                authorName: String(localized: "writeExperience.feed.currentUser"),
                createdAt: response.createdAt,
                country: country,
                tag: subDiscovery.tag,
                content: subDiscovery.content,
                isCurrentUser: true
            )
        }
    }

    private func makeTravelerDiscovery(
        id: Int,
        authorName: String,
        createdAt: String,
        country: ExperienceCountry,
        tag: String,
        content: String,
        isCurrentUser: Bool
    ) -> TravelerDiscovery? {
        guard let preparationTag = PreparationTag(rawValue: tag) else {
            return nil
        }

        return TravelerDiscovery(
            id: isCurrentUser ? -abs(id) : id,
            authorName: authorName,
            authorAvatar: avatar(for: id),
            createdAt: Self.date(from: createdAt),
            content: content,
            country: country,
            tag: preparationTag
        )
    }

    private func avatar(for id: Int) -> ExperienceAvatar {
        let avatars = ExperienceAvatar.allCases
        return avatars[abs(id) % avatars.count]
    }

    private static func date(from value: String) -> Date {
        if let date = try? Date.ISO8601FormatStyle(
            includingFractionalSeconds: true
        ).parse(value) {
            return date
        }
        return (try? Date.ISO8601FormatStyle().parse(value)) ?? .now
    }
}

private extension ExperienceAvatar {
    static var allCases: [ExperienceAvatar] {
        [.blue, .green, .indigo, .orange, .red, .yellow]
    }
}

extension ExperienceCountry {
    init?(backendCode: String) {
        switch backendCode {
        case "AUSTRALIA": self = .au
        case "BRAZIL": self = .br
        case "GERMANY": self = .de
        case "FRANCE": self = .fr
        case "HONGKONG": self = .hk
        case "JAPAN": self = .jp
        case "SINGAPORE": self = .sg
        case "THAILAND": self = .th
        case "TAIWAN": self = .tw
        case "UK", "UNITED_KINGDOM": self = .uk
        case "USA": self = .us
        case "VIETNAM": self = .vn
        default: return nil
        }
    }
}
