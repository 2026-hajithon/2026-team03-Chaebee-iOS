import Foundation

enum DiscoveryEndpoint: Endpoint {
    case list(page: Int = 0, size: Int = 10)

    var path: String {
        "/discoveries"
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .list(page, size):
            [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        }
    }
}
