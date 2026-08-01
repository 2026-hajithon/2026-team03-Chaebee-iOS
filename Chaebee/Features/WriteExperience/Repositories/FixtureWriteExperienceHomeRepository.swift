import Foundation

struct FixtureWriteExperienceHomeRepository: WriteExperienceHomeRepository {
    func fetchDiscoveries(
        sort: ExperienceFeedSort
    ) async throws -> [TravelerDiscovery] {
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
