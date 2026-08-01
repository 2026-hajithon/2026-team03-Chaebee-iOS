import Foundation

enum LoginProvider: String, Encodable, Sendable {
    case google = "GOOGLE"
    case apple = "APPLE"
    case guest = "GUEST"
}
struct AuthenticationSession: Sendable, Equatable {
    let memberID: Int
    let name: String
    let isGuest: Bool
    let isNewMember: Bool
}

protocol AuthenticationRepository: Sendable {
    func login(
        provider: LoginProvider,
        providerToken: String?
    ) async throws -> AuthenticationSession
}

struct RemoteAuthenticationRepository: AuthenticationRepository {
    let apiClient: any APIClient
    let tokenStore: any AuthTokenStoring

    func login(
        provider: LoginProvider,
        providerToken: String? = nil
    ) async throws -> AuthenticationSession {
        let endpoint = try MemberLoginEndpoint(
            provider: provider,
            providerToken: providerToken
        )
        let response = try await apiClient.request(
            endpoint,
            as: APIResponseDTO<MemberLoginResponseDTO>.self
        )
        let payload = response.data

        try await tokenStore.save(
            AuthTokens(
                accessToken: payload.accessToken,
                refreshToken: payload.refreshToken
            )
        )

        return AuthenticationSession(
            memberID: payload.memberID,
            name: payload.name,
            isGuest: payload.isGuest,
            isNewMember: payload.isNewMember
        )
    }
}
