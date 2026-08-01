import Foundation

final class LocalProfileRepository: ProfileRepository {
    private enum Key {
        static let avatarFileName = "profile.avatarFileName"
        static let memberID = "profile.memberID"
        static let nickname = "profile.nickname"
        static let email = "profile.email"
        static let avatarColor = "profile.avatarColor"
    }

    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let avatarFileName = "profile-avatar.jpg"

    init(
        userDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
    }

    func fetchProfile() -> UserProfile {
        UserProfile(
            nickname: userDefaults.string(forKey: Key.nickname)
                ?? String(localized: "profile.fixture.nickname"),
            email: userDefaults.string(forKey: Key.email)
                ?? "chicken.banana@mail.com",
            avatarColor: resolvedAvatarColor(),
            avatarData: loadAvatarData()
        )
    }

    func syncAuthenticatedProfile(
        memberID: Int,
        nickname: String,
        email: String
    ) -> UserProfile {
        let storedMemberID = userDefaults.object(forKey: Key.memberID) as? Int

        if storedMemberID != memberID {
            userDefaults.set(memberID, forKey: Key.memberID)
            userDefaults.set(nickname, forKey: Key.nickname)
            userDefaults.set(email, forKey: Key.email)
            assignRandomAvatarColor()
            removeAvatarData()
        } else {
            if userDefaults.string(forKey: Key.nickname) == nil {
                userDefaults.set(nickname, forKey: Key.nickname)
            }
            if userDefaults.string(forKey: Key.email) == nil {
                userDefaults.set(email, forKey: Key.email)
            }
        }

        return fetchProfile()
    }

    func updateProfile(nickname: String, email: String) -> UserProfile {
        userDefaults.set(nickname, forKey: Key.nickname)
        userDefaults.set(email, forKey: Key.email)
        return fetchProfile()
    }

    func updateAvatar(_ data: Data?) -> UserProfile {
        if let data {
            saveAvatarData(data)
        } else {
            removeAvatarData()
        }

        return fetchProfile()
    }

    private func loadAvatarData() -> Data? {
        guard
            let storedFileName = userDefaults.string(forKey: Key.avatarFileName),
            let fileURL = avatarDirectoryURL?.appendingPathComponent(storedFileName)
        else {
            return nil
        }

        return try? Data(contentsOf: fileURL)
    }

    private func resolvedAvatarColor() -> ExperienceAvatar {
        if let rawValue = userDefaults.string(forKey: Key.avatarColor),
           let color = ExperienceAvatar(rawValue: rawValue) {
            return color
        }

        return assignRandomAvatarColor()
    }

    @discardableResult
    private func assignRandomAvatarColor() -> ExperienceAvatar {
        let color = ExperienceAvatar.allCases.randomElement() ?? .blue
        userDefaults.set(color.rawValue, forKey: Key.avatarColor)
        return color
    }

    private func saveAvatarData(_ data: Data) {
        guard let directoryURL = avatarDirectoryURL else { return }

        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            let fileURL = directoryURL.appendingPathComponent(avatarFileName)
            try data.write(to: fileURL, options: .atomic)
            userDefaults.set(avatarFileName, forKey: Key.avatarFileName)
        } catch {
            userDefaults.removeObject(forKey: Key.avatarFileName)
        }
    }

    private func removeAvatarData() {
        if
            let storedFileName = userDefaults.string(forKey: Key.avatarFileName),
            let fileURL = avatarDirectoryURL?.appendingPathComponent(storedFileName)
        {
            try? fileManager.removeItem(at: fileURL)
        }

        userDefaults.removeObject(forKey: Key.avatarFileName)
    }

    private var avatarDirectoryURL: URL? {
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Profile", isDirectory: true)
    }
}
