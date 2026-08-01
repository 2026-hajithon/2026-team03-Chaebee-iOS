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
            if let payload = try? makeJSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw APIError.server(
                    status: httpResponse.statusCode,
                    code: payload.code,
                    message: payload.message
                )
            }
            throw APIError.invalidStatusCode(httpResponse.statusCode)
        }

        if data.isEmpty {
            guard let emptyResponse = EmptyResponseDTO() as? Response else {
                throw APIError.emptyResponse
            }
            return emptyResponse
        }

        do {
            return try makeJSONDecoder().decode(type, from: data)
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
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        endpoint.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if endpoint.requiresAuthentication,
           let accessToken = await accessTokenProvider(),
           !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

private struct ServerErrorResponse: Decodable {
    let code: String?
    let message: String
}
