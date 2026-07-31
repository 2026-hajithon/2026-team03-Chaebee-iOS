import Foundation

protocol UserDefaultsStoring {
    func bool(forKey key: String) -> Bool
    func integer(forKey key: String) -> Int
    func string(forKey key: String) -> String?
    func data(forKey key: String) -> Data?

    func set(_ value: Bool, forKey key: String)
    func set(_ value: Int, forKey key: String)
    func set(_ value: String?, forKey key: String)
    func set(_ value: Data?, forKey key: String)

    func removeObject(forKey key: String)
}
