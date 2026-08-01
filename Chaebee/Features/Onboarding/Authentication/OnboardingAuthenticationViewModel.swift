import Foundation
import Combine

@MainActor
final class OnboardingAuthenticationViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any AuthenticationRepository
    private let googleSignInService: any GoogleSignInServicing

    init(
        repository: any AuthenticationRepository,
        googleSignInService: any GoogleSignInServicing
    ) {
        self.repository = repository
        self.googleSignInService = googleSignInService
    }

    func signInWithGoogle() async -> AuthenticationSession? {
        await authenticate {
            let providerToken = try await googleSignInService.signIn()
            return try await repository.login(
                provider: .google,
                providerToken: providerToken
            )
        }
    }

    func continueAsGuest() async -> AuthenticationSession? {
        await authenticate {
            try await repository.login(
                provider: .guest,
                providerToken: nil
            )
        }
    }

    func showAppleLoginUnavailable() {
        errorMessage = String(localized: "onboarding.login.error.appleUnavailable")
    }

    private func authenticate(
        operation: () async throws -> AuthenticationSession
    ) async -> AuthenticationSession? {
        guard !isLoading else { return nil }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            return try await operation()
        } catch let error as CancellationError {
            _ = error
            return nil
        } catch {
            let nsError = error as NSError
            if nsError.domain == "com.google.GIDSignIn", nsError.code == -5 {
                return nil
            }
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
