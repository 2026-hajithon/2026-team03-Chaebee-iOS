import Combine
import Foundation

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile

    private let repository: ProfileRepository

    init(repository: ProfileRepository? = nil) {
        let repository = repository ?? LocalProfileRepository()
        self.repository = repository
        profile = repository.fetchProfile()
    }

    func updateAvatar(with data: Data) {
        profile = repository.updateAvatar(data)
    }

    func updateNickname(_ nickname: String) {
        profile = repository.updateProfile(
            nickname: nickname,
            email: profile.email
        )
    }

    func deleteAvatar() {
        profile = repository.updateAvatar(nil)
    }
}
