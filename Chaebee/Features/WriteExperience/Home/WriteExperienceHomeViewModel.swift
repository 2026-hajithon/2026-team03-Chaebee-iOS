import Combine
import Foundation

@MainActor
final class WriteExperienceHomeViewModel: ObservableObject {
    @Published private(set) var discoveries: [TravelerDiscovery] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var currentUserAvatarData: Data?

    private let repository: any WriteExperienceHomeRepository
    private let profileRepository: ProfileRepository
    private let sort: ExperienceFeedSort = .latest

    init(
        repository: any WriteExperienceHomeRepository,
        profileRepository: ProfileRepository? = nil
    ) {
        self.repository = repository
        self.profileRepository = profileRepository ?? LocalProfileRepository()
        currentUserAvatarData = self.profileRepository.fetchProfile().avatarData
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            discoveries = try await repository.fetchDiscoveries(sort: sort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retry() async {
        discoveries = []
        await load()
    }

    func register(_ request: WriteExperienceRequest) async -> Bool {
        currentUserAvatarData = profileRepository.fetchProfile().avatarData

        do {
            let newDiscoveries = try await repository.registerDiscovery(
                request: request
            )
            discoveries.insert(contentsOf: newDiscoveries, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func avatarData(for discovery: TravelerDiscovery) -> Data? {
        discovery.id < 0 ? currentUserAvatarData : nil
    }
}
