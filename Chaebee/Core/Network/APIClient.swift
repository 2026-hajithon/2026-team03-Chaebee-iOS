protocol APIClient: Sendable {
    func request<Response: Decodable>(
        _ endpoint: any Endpoint,
        as type: Response.Type
    ) async throws -> Response
}

extension APIClient {
    func request(_ endpoint: any Endpoint) async throws {
        let _: EmptyResponseDTO = try await request(endpoint, as: EmptyResponseDTO.self)
    }
}
