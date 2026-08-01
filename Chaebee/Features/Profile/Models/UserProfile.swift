import Foundation

struct UserProfile: Equatable, Sendable {
    let nickname: String
    let email: String
    var avatarData: Data?
}
