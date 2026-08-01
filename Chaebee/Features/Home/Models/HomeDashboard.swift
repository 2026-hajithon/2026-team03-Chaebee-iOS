import Foundation

struct HomeDashboard: Equatable, Sendable {
    let trips: [HomeTripSummary]
    let editorDiscoveries: [HomeDiscoverySummary]

    var hasRegisteredTrip: Bool { !trips.isEmpty }
}

struct HomeTripSummary: Equatable, Identifiable, Sendable {
    let id: Int
    let destinationName: String
    let countryCode: String
    let flagAssetName: String
    let dDay: Int
    let completedCount: Int
    let totalCount: Int
    let timelineDestination: FixturePreparationTimelineRepository.Destination

    var progressPercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount) * 100).rounded())
    }
}

struct HomeDiscoverySummary: Equatable, Identifiable, Sendable {
    let id: Int
    let tag: PreparationTag
    let iconAssetName: String
    let timing: String
    let title: String
    let content: String
}
