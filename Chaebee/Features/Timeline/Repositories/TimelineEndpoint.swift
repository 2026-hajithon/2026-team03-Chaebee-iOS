import Foundation

enum TimelineEndpoint: Endpoint {
    case timeline(tripID: Int)
    case updateChecklistItem(id: Int, isChecked: Bool)

    var path: String {
        switch self {
        case let .timeline(tripID):
            "/trips/\(tripID)/timeline"
        case let .updateChecklistItem(id, _):
            "/checklist-items/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .timeline:
            .get
        case .updateChecklistItem:
            .patch
        }
    }

    var headers: [String: String] {
        switch self {
        case .updateChecklistItem:
            ["Content-Type": "application/json"]
        default:
            [:]
        }
    }

    var body: Data? {
        guard case let .updateChecklistItem(_, isChecked) = self else { return nil }
        return try? JSONEncoder().encode(ChecklistUpdateRequestDTO(isChecked: isChecked))
    }
}
