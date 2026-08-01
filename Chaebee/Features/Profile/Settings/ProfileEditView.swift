import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: ProfileSettingsViewModel

    @State private var nickname: String
    @State private var hasEditedNickname = false
    @State private var isPhotoActionsPresented = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var isCameraUnavailablePresented = false

    init(viewModel: ProfileSettingsViewModel) {
        self.viewModel = viewModel
        _nickname = State(initialValue: viewModel.profile.nickname)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header

                avatarButton
                    .padding(.top, 28)

                nicknameForm
                    .padding(.top, 36)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, CBSpacing.medium)

            if validationMessage != nil {
                validationToast
                    .padding(.horizontal, CBSpacing.medium)
                    .padding(.bottom, CBSpacing.medium)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
                    .zIndex(5)
            }

            if isPhotoActionsPresented {
                ProfilePhotoActionOverlay(
                    selectedPhoto: $selectedPhoto,
                    onCamera: presentCamera,
                    onDelete: deleteProfilePhoto,
                    onDismiss: dismissPhotoActions
                )
            }
        }
        .background(Color.white)
        .animation(.easeOut(duration: CBAnimation.quickDuration), value: validationMessage)
        .animation(.easeInOut(duration: 0.2), value: isPhotoActionsPresented)
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await loadSelectedPhoto(item) }
        }
        .onChange(of: nickname) { _, newValue in
            if newValue.count > 10 {
                nickname = String(newValue.prefix(10))
                return
            }

            hasEditedNickname = newValue != viewModel.profile.nickname
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraImagePicker { image in
                guard let data = image.jpegData(compressionQuality: 0.85) else { return }
                viewModel.updateAvatar(with: data)
            }
            .ignoresSafeArea()
        }
        .alert("profile.camera.unavailable.title", isPresented: $isCameraUnavailablePresented) {
            Button("common.confirm", role: .cancel) {}
        } message: {
            Text("profile.camera.unavailable.message")
        }
    }

    private var avatarButton: some View {
        Button {
            isPhotoActionsPresented = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                ProfileAvatarView(
                    imageData: viewModel.profile.avatarData,
                    avatarColor: viewModel.profile.avatarColor,
                    size: 96
                )

                Image(.profileCamera)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
                    .frame(width: 16, height: 16)
                    .frame(width: 32, height: 32)
                    .background(CBColor.blue5, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    }
                    .offset(x: 2, y: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("profile.photo.edit"))
    }

    private var header: some View {
        ZStack {
            Text("profile.edit.title")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray9)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(CBColor.gray6)
                        .frame(width: 44, height: 44)
                        .background(CBColor.gray2, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("common.close"))

                Spacer()

                Button {
                    save()
                } label: {
                    Text("profile.edit.save")
                        .cbTypography(.body4)
                        .foregroundStyle(isValidNickname ? Color.white : CBColor.gray4)
                        .frame(width: 52, height: 44)
                        .background(isValidNickname ? CBColor.blue5 : CBColor.gray2, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!isValidNickname)
            }
        }
        .frame(height: 60)
    }

    private var nicknameForm: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Text("profile.edit.nickname.label")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray9)

            Text("profile.edit.nickname.helper")
                .cbTypography(.body2)
                .foregroundStyle(CBColor.gray5)

            CBTextField(
                text: $nickname,
                placeholder: "profile.edit.nickname.placeholder",
                autoFocus: true
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }

    private var validationToast: some View {
        HStack(spacing: CBSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(CBColor.yellow)
                .frame(width: 24, height: 24)

            if let validationMessage {
                Text(validationMessage)
                    .cbTypography(.body2)
                    .foregroundStyle(Color.white)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, CBSpacing.medium)
        .frame(height: 48)
        .background(CBColor.gray5, in: RoundedRectangle(cornerRadius: CBRadius.medium))
    }

    private var trimmedNickname: String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasValidLength: Bool {
        (2...10).contains(trimmedNickname.count)
    }

    private var hasAllowedCharacters: Bool {
        trimmedNickname.range(
            of: "^[가-힣A-Za-z0-9]+$",
            options: .regularExpression
        ) != nil
    }

    private var isValidNickname: Bool {
        hasValidLength && hasAllowedCharacters && nickname == trimmedNickname
    }

    private var validationMessage: LocalizedStringKey? {
        guard hasEditedNickname, !isValidNickname else { return nil }

        // Korean keyboards expose a single consonant or vowel while the user
        // is still composing a syllable. Avoid showing an error mid-composition.
        guard trimmedNickname.count >= 2 else { return nil }

        if !hasValidLength {
            return "profile.edit.nickname.lengthError"
        }

        return "profile.edit.nickname.characterError"
    }

    private func save() {
        guard isValidNickname else { return }
        viewModel.updateNickname(trimmedNickname)
        dismiss()
    }

    private func presentCamera() {
        isPhotoActionsPresented = false

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraUnavailableAlert()
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPresented = true
        case .notDetermined:
            Task {
                let isGranted = await AVCaptureDevice.requestAccess(for: .video)
                if isGranted {
                    isCameraPresented = true
                } else {
                    presentCameraUnavailableAlert()
                }
            }
        case .denied, .restricted:
            presentCameraUnavailableAlert()
        @unknown default:
            presentCameraUnavailableAlert()
        }
    }

    private func presentCameraUnavailableAlert() {
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            isCameraUnavailablePresented = true
        }
    }

    private func deleteProfilePhoto() {
        viewModel.deleteAvatar()
        selectedPhoto = nil
        dismissPhotoActions()
    }

    private func dismissPhotoActions() {
        isPhotoActionsPresented = false
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        defer {
            selectedPhoto = nil
            isPhotoActionsPresented = false
        }

        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            viewModel.updateAvatar(with: data)
        }
    }
}

#Preview {
    ProfileEditView(viewModel: ProfileSettingsViewModel())
        .environment(\.locale, Locale(identifier: "ko"))
}
