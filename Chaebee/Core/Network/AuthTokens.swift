import Foundation
import Security

struct AuthTokens: Codable, Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
}

protocol AuthTokenStoring: Sendable {
    func tokens() async throws -> AuthTokens?
    func accessToken() async -> String?
    func save(_ tokens: AuthTokens) async throws
    func clear() async throws
}

actor KeychainAuthTokenStore: AuthTokenStoring {
    private let service: String
    private let account: String

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.chaebee.app",
        account: String = "authentication.tokens"
    ) {
        self.service = service
        self.account = account
    }

    func tokens() throws -> AuthTokens? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unhandledStatus(status)
        }

        do {
            return try JSONDecoder().decode(AuthTokens.self, from: data)
        } catch {
            throw KeychainError.invalidStoredData
        }
    }

    func accessToken() -> String? {
        try? tokens()?.accessToken
    }

    func save(_ tokens: AuthTokens) throws {
        let data = try JSONEncoder().encode(tokens)
        let attributes = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var query = baseQuery
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandledStatus(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unhandledStatus(updateStatus)
        }
    }

    func clear() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

enum KeychainError: Error {
    case invalidStoredData
    case unhandledStatus(OSStatus)
}
