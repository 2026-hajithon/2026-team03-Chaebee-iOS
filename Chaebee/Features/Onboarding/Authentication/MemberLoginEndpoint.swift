import Foundation

struct MemberLoginEndpoint: Endpoint {
    let path = "/members/login"
    let method = HTTPMethod.post
    let requiresAuthentication = false
    let body: Data?

    init(
        provider: LoginProvider,
        providerToken: String?
    ) throws {
        body = try JSONEncoder().encode(
            MemberLoginRequestDTO(
                provider: provider,
                providerToken: providerToken
            )
        )
    }
}
private struct MemberLoginRequestDTO: Encodable {
    let provider: LoginProvider
    let providerToken: String?
}

struct MemberLoginResponseDTO: Decodable {
    let memberID: Int
    let name: String
    let isGuest: Bool
    let isNewMember: Bool
    let accessToken: String
    let refreshToken: String

    private enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case name
        case isGuest
        case isNewMember
        case accessToken
        case refreshToken
    }
}
