import Foundation

protocol ProfileRepository: AnyObject {
    func fetchProfile() -> UserProfile
    func updateProfile(nickname: String, email: String) -> UserProfile
    func updateAvatar(_ data: Data?) -> UserProfile
}
