import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed(Error)
    case transportError(Error)
}
