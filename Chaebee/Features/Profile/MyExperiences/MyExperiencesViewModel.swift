import Combine
import Foundation

@MainActor
final class MyExperiencesViewModel: ObservableObject {
    @Published private(set) var discoveries: [TravelerDiscovery] = []
    @Published private(set) var avatarData: Data?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: any WriteExperienceHomeRepository
    private let profileRepository: ProfileRepository

    init(
        repository: (any WriteExperienceHomeRepository)? = nil,
        profileRepository: ProfileRepository? = nil
    ) {
        self.repository = repository ?? FixtureWriteExperienceHomeRepository()
        self.profileRepository = profileRepository ?? LocalProfileRepository()
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        avatarData = profileRepository.fetchProfile().avatarData

        do {
            discoveries = try await repository.fetchMyDiscoveries()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
