import Foundation

struct RemoteWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    let apiClient: any APIClient
    private let profileRepository: ProfileRepository

    init(
        apiClient: any APIClient,
        profileRepository: ProfileRepository = LocalProfileRepository()
    ) {
        self.apiClient = apiClient
        self.profileRepository = profileRepository
    }

    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
        let response: APIResponseDTO<DiscoveryPageResponseDTO> = try await apiClient.request(
            DiscoveryEndpoint.list(),
            as: APIResponseDTO<DiscoveryPageResponseDTO>.self
        )
        let currentUserDiscoveryIDs = await fetchCurrentUserDiscoveryIDs()

        return response.data.content.flatMap {
            map(
                $0,
                isCurrentUser: currentUserDiscoveryIDs.contains($0.discoveryID)
            )
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

    private func fetchCurrentUserDiscoveryIDs() async -> Set<Int> {
        do {
            let response: APIResponseDTO<[DiscoveryListItemResponseDTO]> = try await apiClient.request(
                DiscoveryEndpoint.mine,
                as: APIResponseDTO<[DiscoveryListItemResponseDTO]>.self
            )
            return Set(response.data.map(\.discoveryID))
        } catch {
#if DEBUG
            print("[DiscoveryAudit] GET /discoveries/me failed: \(error.localizedDescription)")
#endif
            return []
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

        if subDiscoveries.isEmpty {
            let mockDetails = mockDetails(for: response.discoveryID)
            return [
                makeTravelerDiscovery(
                    id: response.discoveryID,
                    authorName: response.authorName,
                    createdAt: response.createdAt,
                    country: country,
                    tag: response.tag ?? mockDetails.tag.rawValue,
                    content: response.content ?? mockDetails.content,
                    isCurrentUser: isCurrentUser
                )
            ]
        }

        return subDiscoveries.map { subDiscovery in
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

        let authorName = profileRepository.fetchProfile().nickname

        return response.subDiscoveries.map { subDiscovery in
            makeTravelerDiscovery(
                id: subDiscovery.subDiscoveryID,
                authorName: authorName,
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
        tag: String?,
        content: String?,
        isCurrentUser: Bool
    ) -> TravelerDiscovery {
        TravelerDiscovery(
            id: isCurrentUser ? -abs(id) : id,
            authorName: authorName,
            authorAvatar: avatar(for: authorName),
            createdAt: Self.date(from: createdAt),
            content: content,
            country: country,
            tag: tag.flatMap(PreparationTag.init(rawValue:))
        )
    }

    private func avatar(for authorName: String) -> ExperienceAvatar {
        let stableHash = authorName.utf8.reduce(UInt64(5_381)) { hash, byte in
            ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        let avatars = ExperienceAvatar.allCases
        return avatars[Int(stableHash % UInt64(avatars.count))]
    }

    private func mockDetails(
        for discoveryID: Int
    ) -> (tag: PreparationTag, content: String) {
        switch abs(discoveryID % 5) {
        case 0:
            return (
                .passport,
                "출국 전에 여권 유효기간이 충분히 남았는지 미리 확인해 두세요."
            )
        case 1:
            return (
                .exchange,
                "공항보다 시내 환전소의 환율이 더 좋은 경우가 많아 미리 비교해 보는 게 좋아요."
            )
        case 2:
            return (
                .esimRoaming,
                "현지 도착 전에 eSIM을 설치해 두면 공항에서 바로 데이터를 사용할 수 있어요."
            )
        case 3:
            return (
                .adapter,
                "숙소의 콘센트 규격과 전압을 확인하고 멀티 어댑터를 챙기면 편리해요."
            )
        default:
            return (
                .transitCard,
                "교통카드를 미리 준비하면 현지 대중교통을 더 빠르고 편하게 이용할 수 있어요."
            )
        }
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
