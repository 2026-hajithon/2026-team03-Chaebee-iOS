import Combine
import Foundation

@MainActor
final class WriteExperienceInputViewModel: ObservableObject {
    static let maximumDiscoveryCount = 3

    @Published private(set) var draft = WriteExperienceDraft()

    var canProceed: Bool { draft.canProceed }
    var hasReachedDiscoveryLimit: Bool {
        draft.discoveries.count >= Self.maximumDiscoveryCount
    }

    func selectLocation(_ location: ExperienceLocation) {
        draft.location = location
    }

    func selectTravelType(_ travelType: ExperienceTravelType) {
        draft.travelType = travelType
    }

    @discardableResult
    func addDiscovery(_ discovery: ExperienceDraftDiscovery) -> Bool {
        guard !hasReachedDiscoveryLimit else { return false }
        draft.discoveries.append(discovery)
        return true
    }

    func removeDiscovery(id: UUID) {
        draft.discoveries.removeAll { $0.id == id }
    }

    func updateDiscovery(_ discovery: ExperienceDraftDiscovery) {
        guard let index = draft.discoveries.firstIndex(where: {
            $0.id == discovery.id
        }) else { return }

        draft.discoveries[index] = discovery
    }

    func makeRequest() -> WriteExperienceRequest? {
        WriteExperienceRequest(draft: draft)
    }
}
