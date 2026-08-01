import Foundation
import Combine

@MainActor
final class OnboardingAuthenticationViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any AuthenticationRepository
    private let googleSignInService: any GoogleSignInServicing
    private let profileRepository: ProfileRepository

    init(
        repository: any AuthenticationRepository,
        googleSignInService: any GoogleSignInServicing,
        profileRepository: ProfileRepository? = nil
    ) {
        self.repository = repository
        self.googleSignInService = googleSignInService
        self.profileRepository = profileRepository ?? LocalProfileRepository()
    }

    func signInWithGoogle() async -> AuthenticationSession? {
        await authenticate {
            let credential = try await googleSignInService.signIn()
            let session = try await repository.login(
                provider: .google,
                providerToken: credential.idToken
            )

            _ = profileRepository.syncAuthenticatedProfile(
                memberID: session.memberID,
                nickname: credential.name ?? session.name,
                email: credential.email ?? ""
            )
            return session
        }
    }

    func continueAsGuest() async -> AuthenticationSession? {
        await authenticate {
            let session = try await repository.login(
                provider: .guest,
                providerToken: nil
            )

            _ = profileRepository.syncAuthenticatedProfile(
                memberID: session.memberID,
                nickname: session.name,
                email: ""
            )
            return session
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
