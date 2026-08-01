import Foundation

struct DefaultAPIClient: APIClient {
    typealias AccessTokenProvider = @Sendable () async -> String?

    let baseURL: URL
    let session: URLSession
    let accessTokenProvider: AccessTokenProvider

    init(
        baseURL: URL,
        session: URLSession = .shared,
        accessTokenProvider: @escaping AccessTokenProvider = { nil }
    ) {
        self.baseURL = baseURL
        self.session = session
        self.accessTokenProvider = accessTokenProvider
    }

    func request<Response: Decodable>(
        _ endpoint: any Endpoint,
        as type: Response.Type
    ) async throws -> Response {
        let request = try await makeRequest(for: endpoint)
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            if let payload = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw APIError.server(
                    status: httpResponse.statusCode,
                    code: payload.code,
                    message: payload.message
                )
            }
            throw APIError.invalidStatusCode(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private func makeRequest(for endpoint: any Endpoint) async throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        let basePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointPath = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/" + [basePath, endpointPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let accessToken = await accessTokenProvider(), !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

private struct ServerErrorResponse: Decodable {
    let code: String?
    let message: String
}
