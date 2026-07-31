protocol APIClient {
    func request<Response: Decodable>(
        _ endpoint: any Endpoint,
        as type: Response.Type
    ) async throws -> Response
}
