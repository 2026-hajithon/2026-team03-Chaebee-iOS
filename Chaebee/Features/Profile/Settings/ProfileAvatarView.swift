import SwiftUI
import UIKit

struct ProfileAvatarView: View {
    let imageData: Data?
    var avatarColor: ExperienceAvatar = .orange
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(avatarColor.imageResource)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
