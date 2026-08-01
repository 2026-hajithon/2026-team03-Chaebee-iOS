import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(Int)
    case server(status: Int, code: String?, message: String)
    case decodingFailed(Error)
    case transportError(Error)
}
