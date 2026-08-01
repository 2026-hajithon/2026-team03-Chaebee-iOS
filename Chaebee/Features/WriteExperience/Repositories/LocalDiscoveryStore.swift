import Foundation

protocol LocalDiscoveryStoring: AnyObject {
    func fetchDiscoveries() -> [TravelerDiscovery]
    func prependDiscoveries(_ discoveries: [TravelerDiscovery])
    func nextDiscoveryID() -> Int
}

final class UserDefaultsLocalDiscoveryStore: LocalDiscoveryStoring {
    private enum Key {
        static let discoveries = "writeExperience.localDiscoveries"
        static let nextDiscoveryID = "writeExperience.nextLocalDiscoveryID"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchDiscoveries() -> [TravelerDiscovery] {
        guard let data = userDefaults.data(forKey: Key.discoveries) else {
            return []
        }

        return (try? decoder.decode([TravelerDiscovery].self, from: data)) ?? []
    }

    func prependDiscoveries(_ discoveries: [TravelerDiscovery]) {
        let updatedDiscoveries = discoveries + fetchDiscoveries()
        guard let data = try? encoder.encode(updatedDiscoveries) else { return }
        userDefaults.set(data, forKey: Key.discoveries)
    }

    func nextDiscoveryID() -> Int {
        let storedID = userDefaults.integer(forKey: Key.nextDiscoveryID)
        let nextID = storedID < 0 ? storedID : -1
        userDefaults.set(nextID - 1, forKey: Key.nextDiscoveryID)
        return nextID
    }
}
