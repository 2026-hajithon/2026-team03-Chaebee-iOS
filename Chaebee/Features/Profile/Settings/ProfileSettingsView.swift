import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

struct ProfileSettingsView: View {
    @AppStorage("chaebee.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("chaebee.isLoggedIn") private var isLoggedIn = false
    @StateObject private var viewModel: ProfileSettingsViewModel
    @State private var isPhotoActionsPresented = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var isCameraUnavailablePresented = false
    @State private var isProfileEditPresented = false
    @State private var accountAlert: AccountAlert?

    init(viewModel: ProfileSettingsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ProfileSettingsViewModel())
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    profileSection
                    activitySection
                    accountSection
                    appInformation
                }
                .padding(.horizontal, CBSpacing.medium)
                .padding(.top, 44)
                .padding(.bottom, CBSpacing.xLarge)
            }
            .scrollIndicators(.hidden)
            .background(CBColor.gray1)

            if isPhotoActionsPresented {
                ProfilePhotoActionOverlay(
                    selectedPhoto: $selectedPhoto,
                    onCamera: presentCamera,
                    onDelete: deleteProfilePhoto,
                    onDismiss: dismissPhotoActions
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPhotoActionsPresented)
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await loadSelectedPhoto(item) }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraImagePicker { image in
                guard let data = image.jpegData(compressionQuality: 0.85) else { return }
                viewModel.updateAvatar(with: data)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $isProfileEditPresented) {
            ProfileEditView(viewModel: viewModel)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .alert("profile.camera.unavailable.title", isPresented: $isCameraUnavailablePresented) {
            Button("common.confirm", role: .cancel) {}
        } message: {
            Text("profile.camera.unavailable.message")
        }
        .alert(item: $accountAlert) { alert in
            switch alert {
            case .logout:
                Alert(
                    title: Text("profile.logout.confirm.title"),
                    message: Text("profile.logout.confirm.message"),
                    primaryButton: .destructive(Text("profile.logout")) {
                        isLoggedIn = false
                        hasCompletedOnboarding = false
                    },
                    secondaryButton: .cancel(Text("common.cancel"))
                )
            case .withdraw:
                Alert(
                    title: Text("profile.withdraw.confirm.title"),
                    message: Text("profile.withdraw.confirm.message"),
                    primaryButton: .destructive(Text("profile.withdraw")) {},
                    secondaryButton: .cancel(Text("common.cancel"))
                )
            }
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: CBSpacing.medium) {
            sectionTitle("profile.section.profile")

            HStack(spacing: CBSpacing.medium) {
                Button {
                    isPhotoActionsPresented = true
                } label: {
                    ProfileAvatarView(imageData: viewModel.profile.avatarData, size: 44)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.profile.nickname)
                        .cbTypography(.subhead4)
                        .foregroundStyle(CBColor.gray8)

                    Text(viewModel.profile.email)
                        .cbTypography(.body3)
                        .foregroundStyle(CBColor.gray5)
                }

                Spacer(minLength: CBSpacing.small)

                Button {
                    isProfileEditPresented = true
                } label: {
                    Image(.profileEdit)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(CBColor.gray4)
                        .frame(width: 24, height: 24)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("profile.edit.title"))
            }
            .padding(.horizontal, CBSpacing.medium)
            .frame(height: 68)
            .background(Color.white, in: RoundedRectangle(cornerRadius: CBRadius.large, style: .continuous))
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: CBSpacing.medium) {
            sectionTitle("profile.section.activity")

            NavigationLink {
                MyExperiencesView()
            } label: {
                settingsRow("profile.registeredDiscoveries")
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: CBRadius.large,
                            style: .continuous
                        )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, CBSpacing.xLarge)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: CBSpacing.medium) {
            sectionTitle("profile.section.account")

            VStack(spacing: 0) {
                accountButton("profile.logout") {
                    accountAlert = .logout
                }

                divider

                accountButton("profile.withdraw") {
                    accountAlert = .withdraw
                }

                divider

                NavigationLink {
                    ProfileLegalDocumentView(document: .terms)
                } label: {
                    settingsRow("profile.terms")
                }
                .buttonStyle(.plain)

                divider

                NavigationLink {
                    ProfileLegalDocumentView(document: .privacy)
                } label: {
                    settingsRow("profile.privacy")
                }
                .buttonStyle(.plain)
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: CBRadius.large, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.large, style: .continuous))
        }
        .padding(.top, CBSpacing.xLarge)
    }

    private var appInformation: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Text(String(format: String(localized: "profile.version.format"), appVersion))
                .cbTypography(.body2)
                .foregroundStyle(CBColor.gray8)

            Text("profile.disclaimer")
                .cbTypography(.caption1)
                .foregroundStyle(CBColor.gray5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, CBSpacing.xLarge)
        .padding(.horizontal, 4)
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .cbTypography(.head4)
            .foregroundStyle(CBColor.gray9)
    }

    private func settingsRow(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .cbTypography(.head2)
            .foregroundStyle(CBColor.gray8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, CBSpacing.medium)
            .frame(height: 50)
            .background(Color.white)
            .contentShape(Rectangle())
    }

    private func accountButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRow(title)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(CBColor.gray3)
            .frame(height: 1)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
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

private enum AccountAlert: Identifiable {
    case logout
    case withdraw

    var id: Self { self }
}

#Preview {
    NavigationStack {
        ProfileSettingsView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
