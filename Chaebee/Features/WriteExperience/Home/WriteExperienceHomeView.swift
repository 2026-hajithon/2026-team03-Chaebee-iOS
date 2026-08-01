import SwiftUI

struct WriteExperienceHomeView: View {
    @StateObject private var viewModel: WriteExperienceHomeViewModel
    @State private var showsWriteExperience = false
    @State private var showsRegistrationToast = false
    @State private var registrationToastTask: Task<Void, Never>?
    private let locationRepository: any ExperienceLocationRepository

    init(
        repository: any WriteExperienceHomeRepository,
        locationRepository: any ExperienceLocationRepository
    ) {
        self.locationRepository = locationRepository
        _viewModel = StateObject(
            wrappedValue: WriteExperienceHomeViewModel(
                repository: repository
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.discoveries.isEmpty {
                ProgressView()
                    .tint(CBColor.blue5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.errorMessage != nil && viewModel.discoveries.isEmpty {
                errorView
            } else {
                content
            }
        }
        .background(CBColor.gray1)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .fullScreenCover(isPresented: $showsWriteExperience) {
            NavigationStack {
                WriteExperienceInputView(
                    locationRepository: locationRepository
                ) { request in
                    Task {
                        if await viewModel.register(request) {
                            showRegistrationToast()
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showsRegistrationToast {
                registrationSuccessToast
                    .padding(.horizontal, CBSpacing.pageHorizontal)
                    .padding(.bottom, CBSpacing.medium)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CBAppHeader()

                registrationCard
                    .padding(.top, CBSpacing.large)

                if viewModel.discoveries.isEmpty {
                    emptyFeedView
                } else {
                    feedHeader
                        .padding(.top, CBSpacing.xLarge)

                    LazyVStack(spacing: CBSpacing.medium) {
                        ForEach(viewModel.discoveries) { discovery in
                            TravelerDiscoveryCard(
                                discovery: discovery,
                                avatarData: viewModel.avatarData(for: discovery),
                                avatarColor: viewModel.avatarColor(for: discovery)
                            )
                        }
                    }
                    .padding(.top, CBSpacing.medium)
                }
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.medium)
            .padding(.bottom, CBSpacing.xLarge)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.retry()
        }
    }

    private var registrationCard: some View {
        VStack(spacing: CBSpacing.large) {
            HStack(alignment: .center, spacing: CBSpacing.medium) {
                VStack(alignment: .leading, spacing: CBSpacing.small) {
                    Text("writeExperience.home.hero.eyebrow")
                        .cbTypography(.subhead3)
                        .foregroundStyle(CBColor.gray6)

                    Text("writeExperience.home.hero.title")
                        .cbTypography(.head3)
                        .foregroundStyle(CBColor.blue5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(.destination)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 112, height: 112)
                    .accessibilityHidden(true)
            }

            CBButton("writeExperience.home.hero.button") {
                showsWriteExperience = true
            }
        }
        .padding(CBSpacing.medium)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }

    private var feedHeader: some View {
        HStack(alignment: .center) {
            Text("writeExperience.home.feed.title")
                .cbTypography(.head5)
                .foregroundStyle(CBColor.gray9)

            Spacer()

            Label(
                "writeExperience.home.sort.latest",
                systemImage: "arrow.up.arrow.down"
            )
            .cbTypography(.body4)
            .foregroundStyle(CBColor.gray6)
        }
    }

    private var emptyFeedView: some View {
        VStack(spacing: CBSpacing.large) {
            Image("emptyDiscovery")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 95)
                .accessibilityHidden(true)

            Text("writeExperience.home.empty.message")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 96)
        .padding(.bottom, CBSpacing.xLarge)
    }

    private var registrationSuccessToast: some View {
        HStack(spacing: CBSpacing.medium) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 24, height: 24)
                .background(CBColor.blue5, in: Circle())

            Text("writeExperience.registration.success")
                .cbTypography(.body4)
                .foregroundStyle(Color.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, CBSpacing.medium)
        .frame(height: 56)
        .background(CBColor.gray5)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
    }

    private func showRegistrationToast() {
        registrationToastTask?.cancel()

        withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
            showsRegistrationToast = true
        }

        registrationToastTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
                showsRegistrationToast = false
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: CBSpacing.medium) {
            Text("writeExperience.home.error.title")
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray8)

            CBButton("writeExperience.home.error.retry") {
                Task {
                    await viewModel.retry()
                }
            }
            .frame(maxWidth: 220)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CBSpacing.pageHorizontal)
    }
}

#Preview {
    NavigationStack {
        WriteExperienceHomeView(
            repository: FixtureWriteExperienceHomeRepository(),
            locationRepository: FixtureExperienceLocationRepository()
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("Empty") {
    NavigationStack {
        WriteExperienceHomeView(
            repository: FixtureWriteExperienceHomeRepository(state: .empty),
            locationRepository: FixtureExperienceLocationRepository()
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
