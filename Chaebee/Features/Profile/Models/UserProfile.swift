import Foundation

struct UserProfile: Equatable, Sendable {
    let nickname: String
    let email: String
    let avatarColor: ExperienceAvatar
    var avatarData: Data?
}
