import Foundation

struct APIConfiguration: Sendable {
    static let baseURLKey = "API_BASE_URL"

    let baseURL: URL

    static var current: APIConfiguration {
        let rawValue = ProcessInfo.processInfo.environment[baseURLKey]
            ?? Bundle.main.object(forInfoDictionaryKey: baseURLKey) as? String
            ?? "https://essential-family-display.ngrok-free.dev/api"

        guard let url = URL(string: rawValue),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme),
              url.host != nil else {
            preconditionFailure("\(baseURLKey) must be a valid HTTP(S) URL.")
        }
        return APIConfiguration(baseURL: url)
    }
}
