struct APIResponseDTO<Payload: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: Payload
}

struct EmptyResponseDTO: Decodable {}
