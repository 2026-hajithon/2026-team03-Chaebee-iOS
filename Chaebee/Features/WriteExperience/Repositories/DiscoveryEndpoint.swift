import Foundation

enum DiscoveryEndpoint: Endpoint {
    case list(page: Int = 0, size: Int = 10)
    case register(body: Data)
    case mine

    static func register(request: WriteExperienceRequest) throws -> Self {
        let body = try JSONEncoder().encode(
            DiscoveryRegistrationRequestDTO(
                tripID: request.tripID,
                tripType: request.travelType.rawValue,
                subDiscoveries: request.discoveries.map {
                    SubDiscoveryRegistrationRequestDTO(
                        tag: $0.tag.rawValue,
                        content: $0.content
                    )
                }
            )
        )
        return .register(body: body)
    }

    var path: String {
        switch self {
        case .list, .register:
            "/discoveries"
        case .mine:
            "/discoveries/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .mine:
            .get
        case .register:
            .post
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .list(page, size):
            [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        case .register, .mine:
            []
        }
    }

    var body: Data? {
        guard case let .register(body) = self else { return nil }
        return body
    }
}
