import Foundation

final class DefaultUserDefaultsStore: UserDefaultsStoring {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func bool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }

    func integer(forKey key: String) -> Int {
        userDefaults.integer(forKey: key)
    }

    func string(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func data(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func set(_ value: String?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func set(_ value: Data?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
