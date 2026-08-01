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
#if DEBUG
        logRequest(request, endpoint: endpoint)
#endif
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
#if DEBUG
        logResponse(httpResponse, data: data, endpoint: endpoint)
#endif
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
        if endpoint.requiresAuthentication {
            // Authenticated responses are user-specific even when their URLs are
            // identical. Never let URLCache reuse another session's response.
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
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

#if DEBUG
    private func logRequest(
        _ request: URLRequest,
        endpoint: any Endpoint
    ) {
        let authorizationState = request.value(
            forHTTPHeaderField: "Authorization"
        ) == nil ? "missing" : "attached"

        print(
            "[Network] \(endpoint.method.rawValue) \(endpoint.path) "
                + "authorization=\(authorizationState)"
        )
    }

    private func logResponse(
        _ response: HTTPURLResponse,
        data: Data,
        endpoint: any Endpoint
    ) {
        print(
            "[Network] \(endpoint.method.rawValue) \(endpoint.path) "
                + "status=\(response.statusCode) bytes=\(data.count)"
        )

        let shouldLogResponseBody = endpoint.path.hasPrefix("/trips")
            || endpoint.path.hasPrefix("/discoveries")
            || !(200..<300 ~= response.statusCode)
        guard shouldLogResponseBody else {
            return
        }
        guard
            !data.isEmpty,
            let json = try? JSONSerialization.jsonObject(with: data),
            let redactedData = try? JSONSerialization.data(
                withJSONObject: redactSensitiveValues(in: json),
                options: [.prettyPrinted, .sortedKeys]
            ),
            let text = String(data: redactedData, encoding: .utf8)
        else {
            print("[Network] response body is not JSON")
            return
        }

        print("[Network] response:\n\(text)")
    }

    private func redactSensitiveValues(in value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, item in
                let normalizedKey = item.key.lowercased()
                if normalizedKey.contains("token") || normalizedKey == "authorization" {
                    result[item.key] = "<redacted>"
                } else {
                    result[item.key] = redactSensitiveValues(in: item.value)
                }
            }
        }

        if let array = value as? [Any] {
            return array.map(redactSensitiveValues)
        }

        return value
    }
#endif
}

private struct ServerErrorResponse: Decodable {
    let code: String?
    let message: String
}
