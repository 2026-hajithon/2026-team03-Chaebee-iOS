import SwiftUI

struct MyExperiencesView: View {
    @StateObject private var viewModel: MyExperiencesViewModel

    init(
        repository: (any WriteExperienceHomeRepository)? = nil,
        viewModel: MyExperiencesViewModel? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? MyExperiencesViewModel(repository: repository)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.discoveries.isEmpty {
                ProgressView()
                    .tint(CBColor.blue5)
            } else if let errorMessage = viewModel.errorMessage,
                      viewModel.discoveries.isEmpty {
                Text(verbatim: errorMessage)
                    .cbTypography(.body4)
                    .foregroundStyle(CBColor.gray6)
                    .multilineTextAlignment(.center)
                    .padding(CBSpacing.pageHorizontal)
            } else if viewModel.discoveries.isEmpty {
                emptyView
            } else {
                discoveryList
            }
        }
        .background(CBColor.gray1)
        .navigationTitle("profile.registeredDiscoveries")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var discoveryList: some View {
        ScrollView {
            LazyVStack(spacing: CBSpacing.medium) {
                ForEach(viewModel.discoveries) { discovery in
                    TravelerDiscoveryCard(
                        discovery: discovery,
                        avatarData: viewModel.avatarData
                    )
                }
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.vertical, CBSpacing.medium)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyView: some View {
        VStack(spacing: CBSpacing.medium) {
            Image(.emptyDiscovery)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)

            Text("profile.registeredDiscoveries.empty")
                .cbTypography(.subhead3)
                .foregroundStyle(CBColor.gray4)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        MyExperiencesView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
