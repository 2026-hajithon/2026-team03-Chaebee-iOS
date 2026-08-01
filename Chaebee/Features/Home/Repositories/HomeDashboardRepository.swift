protocol HomeDashboardRepository: Sendable {
    func fetchDashboard() async throws -> HomeDashboard
}
