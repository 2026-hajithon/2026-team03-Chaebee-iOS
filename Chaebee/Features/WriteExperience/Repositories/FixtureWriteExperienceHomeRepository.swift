import Foundation

@MainActor
final class FixtureWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    enum State: Equatable, Sendable {
        case populated
        case empty
    }

    private var discoveries: [TravelerDiscovery]
    private let localStore: LocalDiscoveryStoring

    init(
        state: State = .populated,
        localStore: LocalDiscoveryStoring? = nil
    ) {
        let resolvedStore = localStore ?? UserDefaultsLocalDiscoveryStore()
        self.localStore = resolvedStore

        discoveries = state == .populated
            ? resolvedStore.fetchDiscoveries() + Self.fixtureDiscoveries
            : []
    }

    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
        discoveries
    }

    func registerDiscovery(
        request: WriteExperienceRequest
    ) -> [TravelerDiscovery] {
        let createdAt = Date.now
        let newDiscoveries = request.discoveries.map { discovery in
            return TravelerDiscovery(
                id: localStore.nextDiscoveryID(),
                authorName: String(localized: "writeExperience.feed.currentUser"),
                authorAvatar: .blue,
                createdAt: createdAt,
                content: discovery.content,
                country: request.country,
                tag: discovery.tag
            )
        }

        localStore.prependDiscoveries(newDiscoveries)
        discoveries.insert(contentsOf: newDiscoveries, at: 0)
        return newDiscoveries
    }

    private static var fixtureDiscoveries: [TravelerDiscovery] {
        let now = Date.now

        return [
            TravelerDiscovery(
                id: 1,
                authorName: "안졸리나졸려",
                authorAvatar: .green,
                createdAt: now,
                content: "비짓재팬웹 등록했다고 끝난 게 아니에요. 여권 유효기간 얼마 안 남았으면 그대로 입국 거부될 수 있어요.",
                country: .jp,
                tag: .passport
            ),
            TravelerDiscovery(
                id: 2,
                authorName: "개미핥기",
                authorAvatar: .blue,
                createdAt: now,
                content: "교통카드용은 트래블월렛카드가 제일 나아요. 저 현대카드로 교통카드 쓰려했는데 안되더라고요.",
                country: .sg,
                tag: .transitCard
            ),
            TravelerDiscovery(
                id: 3,
                authorName: "팔랑귀",
                authorAvatar: .orange,
                createdAt: now.addingTimeInterval(-86_400),
                content: "공항에서 바로 쓸 현금은 한국에서 조금만 환전해 가는 편이 편했어요.",
                country: .tw,
                tag: .exchange
            )
        ]
    }
}
