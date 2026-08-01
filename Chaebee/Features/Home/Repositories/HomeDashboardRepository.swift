protocol HomeDashboardRepository: Sendable {
    func fetchDashboard() async throws -> HomeDashboard
    func deleteTrip(id: Int) async throws
}
