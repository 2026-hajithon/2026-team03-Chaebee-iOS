import PhotosUI
import SwiftUI

struct ProfilePhotoActionOverlay: View {
    @Binding var selectedPhoto: PhotosPickerItem?

    let onCamera: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.66)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: CBSpacing.small) {
                actionButton("profile.photo.take", action: onCamera)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    actionLabel("profile.photo.choose", foreground: CBColor.gray9)
                }
                .buttonStyle(.plain)

                actionButton("profile.photo.delete", foreground: CBColor.red, action: onDelete)
            }
            .padding(14)
            .frame(maxWidth: 300)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.28), radius: 28, y: 14)
            .padding(.horizontal, 48)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .zIndex(10)
    }

    private func actionButton(
        _ title: LocalizedStringKey,
        foreground: Color = CBColor.gray9,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            actionLabel(title, foreground: foreground)
        }
        .buttonStyle(.plain)
    }

    private func actionLabel(_ title: LocalizedStringKey, foreground: Color) -> some View {
        Text(title)
            .cbTypography(.title3)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white.opacity(0.38), in: Capsule())
    }
}
