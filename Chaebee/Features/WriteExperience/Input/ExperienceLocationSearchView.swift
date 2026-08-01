import SwiftUI

struct ExperienceLocationSearchView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var locations: [ExperienceLocation] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let repository: any ExperienceLocationRepository
    private let onSelect: (ExperienceLocation) -> Void

    init(
        repository: any ExperienceLocationRepository = FixtureExperienceLocationRepository(),
        onSelect: @escaping (ExperienceLocation) -> Void
    ) {
        self.repository = repository
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: CBSpacing.medium) {
                CBTextField(
                    text: $query,
                    placeholder: "writeExperience.location.placeholder",
                    trailingSystemImage: "magnifyingglass",
                    autoFocus: true
                )

                if isLoading {
                    ProgressView()
                        .tint(CBColor.blue5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    searchMessage(
                        title: errorMessage,
                        actionTitle: "writeExperience.location.retry"
                    ) {
                        Task { await search() }
                    }
                } else if locations.isEmpty {
                    searchMessage(
                        title: String(localized: "writeExperience.location.empty")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: CBSpacing.small) {
                            ForEach(locations) { location in
                                Button {
                                    onSelect(location)
                                    dismiss()
                                } label: {
                                    locationRow(location)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(CBSpacing.pageHorizontal)
            .background(CBColor.gray1)
            .navigationTitle("writeExperience.location.searchTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel") { dismiss() }
                }
            }
            .task(id: query) {
                await search()
            }
        }
    }

    private func locationRow(_ location: ExperienceLocation) -> some View {
        HStack(spacing: CBSpacing.medium) {
            Image(location.country.flagResource)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: CBSpacing.xSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: location.cityName)
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.gray8)

                Text(location.country.localizedName)
                    .cbTypography(.body2)
                    .foregroundStyle(CBColor.gray6)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(CBColor.gray4)
        }
        .padding(CBSpacing.medium)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
    }

    private func search() async {
        errorMessage = nil
        isLoading = true

        do {
            try await Task.sleep(for: .milliseconds(250))
            locations = try await repository.searchLocations(query: query)
            isLoading = false
        } catch is CancellationError {
            return
        } catch {
            locations = []
            errorMessage = String(localized: "writeExperience.location.error")
            isLoading = false
        }
    }

    private func searchMessage(
        title: String,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: CBSpacing.medium) {
            Text(verbatim: title)
                .cbTypography(.body4)
                .foregroundStyle(CBColor.gray6)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.blue5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
