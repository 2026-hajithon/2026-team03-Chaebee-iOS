import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(Int)
    case server(status: Int, code: String?, message: String)
    case emptyResponse
    case decodingFailed(Error)
    case transportError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The API URL is invalid."
        case .invalidResponse:
            "The server response is invalid."
        case let .invalidStatusCode(status):
            "The server returned HTTP \(status)."
        case let .server(_, _, message):
            message
        case .emptyResponse:
            "The server returned an empty response."
        case let .decodingFailed(error):
            "Failed to decode the server response: \(error.localizedDescription)"
        case let .transportError(error):
            error.localizedDescription
        }
    }

    var statusCode: Int? {
        switch self {
        case let .invalidStatusCode(status), let .server(status, _, _):
            status
        default:
            nil
        }
    }

    var serverCode: String? {
        guard case let .server(_, code, _) = self else { return nil }
        return code
    }
}
