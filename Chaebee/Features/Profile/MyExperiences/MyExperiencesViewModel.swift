import Combine
import Foundation

@MainActor
final class MyExperiencesViewModel: ObservableObject {
    @Published private(set) var discoveries: [TravelerDiscovery] = []
    @Published private(set) var avatarData: Data?

    private let discoveryStore: LocalDiscoveryStoring
    private let profileRepository: ProfileRepository

    init(
        discoveryStore: LocalDiscoveryStoring? = nil,
        profileRepository: ProfileRepository? = nil
    ) {
        self.discoveryStore = discoveryStore ?? UserDefaultsLocalDiscoveryStore()
        self.profileRepository = profileRepository ?? LocalProfileRepository()
    }

    func load() {
        discoveries = discoveryStore.fetchDiscoveries()
        avatarData = profileRepository.fetchProfile().avatarData
    }
}
