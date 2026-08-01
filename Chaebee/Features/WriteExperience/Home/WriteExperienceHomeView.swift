import SwiftUI

struct WriteExperienceHomeView: View {
    @StateObject private var viewModel: WriteExperienceHomeViewModel
    @State private var showsWriteExperience = false

    init(repository: (any WriteExperienceHomeRepository)? = nil) {
        let resolvedRepository = repository ?? FixtureWriteExperienceHomeRepository()
        _viewModel = StateObject(
            wrappedValue: WriteExperienceHomeViewModel(
                repository: resolvedRepository
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
        .navigationDestination(isPresented: $showsWriteExperience) {
            WriteExperienceInputView()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CBAppHeader()

                registrationCard
                    .padding(.top, CBSpacing.large)

                feedHeader
                    .padding(.top, CBSpacing.xLarge)

                LazyVStack(spacing: CBSpacing.medium) {
                    ForEach(viewModel.discoveries) { discovery in
                        TravelerDiscoveryCard(discovery: discovery)
                    }
                }
                .padding(.top, CBSpacing.medium)
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
                        .cbTypography(.subhead4)
                        .foregroundStyle(CBColor.gray6)

                    Text("writeExperience.home.hero.title")
                        .cbTypography(.head4)
                        .foregroundStyle(CBColor.blue5)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(.destination)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
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
        WriteExperienceHomeView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
