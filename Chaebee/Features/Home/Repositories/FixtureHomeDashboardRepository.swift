@MainActor
final class FixtureHomeDashboardRepository: HomeDashboardRepository {
    enum State: Sendable {
        case registered
        case singleTrip
        case empty
    }

    private var currentTrips: [HomeTripSummary]

    init(state: State = .empty) {
        let trips = Self.makeTrips()
        switch state {
        case .empty:
            currentTrips = []
        case .singleTrip:
            currentTrips = [trips[0]]
        case .registered:
            currentTrips = trips
        }
    }

    func fetchDashboard() async throws -> HomeDashboard {
        HomeDashboard(trips: currentTrips, editorDiscoveries: discoveries)
    }

    func deleteTrip(id: Int) async throws {
        currentTrips.removeAll { $0.id == id }
    }

    private static func makeTrips() -> [HomeTripSummary] {
        [
            HomeTripSummary(
                id: 12,
                destinationName: "대만 여행",
                countryCode: "TAIWAN",
                flagAssetName: "flagTW",
                dDay: 30,
                completedCount: 4,
                totalCount: 12,
                timelineDestination: .taiwan
            ),
            HomeTripSummary(
                id: 13,
                destinationName: "로스앤젤레스 여행",
                countryCode: "USA",
                flagAssetName: "flagUS",
                dDay: 30,
                completedCount: 4,
                totalCount: 12,
                timelineDestination: .losAngeles
            )
        ]
    }

    nonisolated static var discoveryFixtures: [HomeDiscoverySummary] {
        [
            HomeDiscoverySummary(
                id: 1,
                tag: .exchange,
                iconAssetName: "cash",
                timing: "D-7의 발견",
                title: "공항에서 환전하면 더 비쌀 수 있어요",
                content: "공항 환율은 시중보다 불리한 경우가 많아요. 미리 환전하면 비용을 아낄 수 있어요."
            ),
            HomeDiscoverySummary(
                id: 2,
                tag: .transitCard,
                iconAssetName: "ticketPass",
                timing: "D-7의 발견",
                title: "여행자 패스, 구매 전에 비교해보세요",
                content: "실물카드 발급 여부와 이동 계획에 따라 더 유리한 선택이 달라질 수 있어요."
            ),
            HomeDiscoverySummary(
                id: 3,
                tag: .flightBoarding,
                iconAssetName: "globe",
                timing: "D-1의 발견",
                title: "체크인 전, 마일리지 번호를 확인하세요",
                content: "마일리지 번호가 등록되어 있는지 한 번 더 확인하면 적립 누락을 줄일 수 있어요."
            )
        ]
    }

    private var discoveries: [HomeDiscoverySummary] {
        Self.discoveryFixtures
    }
}
