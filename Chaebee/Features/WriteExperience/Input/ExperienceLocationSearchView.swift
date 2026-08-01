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
                } else if locations.isEmpty && filteredComingSoonDestinations.isEmpty {
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

                            ForEach(filteredComingSoonDestinations) { destination in
                                comingSoonRow(destination)
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

    private func comingSoonRow(_ destination: ComingSoonDestination) -> some View {
        HStack(spacing: CBSpacing.medium) {
            destination.flag
                .frame(width: 48, height: 30)
                .opacity(0.4)

            Text(destination.name)
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray5)

            ComingSoonBadge()

            Spacer()
        }
        .padding(CBSpacing.medium)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
        .accessibilityElement(children: .combine)
    }

    private var filteredComingSoonDestinations: [ComingSoonDestination] {
        let availableCountryCodes = Set(locations.map(\.country.rawValue))
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        return ComingSoonDestination.all.filter { destination in
            guard !availableCountryCodes.contains(destination.countryCode) else {
                return false
            }

            guard !normalizedQuery.isEmpty else { return true }
            return destination.searchAliases.contains {
                $0.localizedCaseInsensitiveContains(normalizedQuery)
            }
        }
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

private struct ComingSoonDestination: Identifiable {
    enum Flag {
        case asset(ImageResource)
        case emoji(String)
    }

    let countryCode: String
    let name: LocalizedStringResource
    let flagValue: Flag
    let aliases: [String]

    var id: String { countryCode }

    @ViewBuilder
    var flag: some View {
        switch flagValue {
        case let .asset(resource):
            Image(resource)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: CBSpacing.xSmall))
        case let .emoji(value):
            Text(verbatim: value)
                .font(.system(size: 32))
        }
    }

    var searchAliases: [String] {
        [String(localized: name)] + aliases
    }

    static let all: [ComingSoonDestination] = [
        .init(countryCode: "JP", name: "country.jp", flagValue: .asset(.flagJP), aliases: ["일본", "Japan"]),
        .init(countryCode: "BR", name: "country.br", flagValue: .asset(.flagBR), aliases: ["브라질", "Brazil"]),
        .init(countryCode: "AU", name: "country.au", flagValue: .asset(.flagAU), aliases: ["호주", "Australia"]),
        .init(countryCode: "TH", name: "country.th", flagValue: .asset(.flagTH), aliases: ["태국", "Thailand"]),
        .init(countryCode: "VN", name: "country.vn", flagValue: .asset(.flagVN), aliases: ["베트남", "Vietnam"]),
        .init(countryCode: "HK", name: "country.hk", flagValue: .asset(.flagHK), aliases: ["홍콩", "Hong Kong"]),
        .init(countryCode: "FR", name: "country.fr", flagValue: .asset(.flagFR), aliases: ["프랑스", "France"]),
        .init(countryCode: "GB", name: "country.uk", flagValue: .asset(.flagUK), aliases: ["영국", "United Kingdom", "UK"]),
        .init(countryCode: "DE", name: "country.de", flagValue: .asset(.flagDE), aliases: ["독일", "Germany"]),
        .init(countryCode: "CA", name: "country.ca", flagValue: .emoji("🇨🇦"), aliases: ["캐나다", "Canada"]),
        .init(countryCode: "CN", name: "country.cn", flagValue: .emoji("🇨🇳"), aliases: ["중국", "China"]),
        .init(countryCode: "ID", name: "country.id", flagValue: .emoji("🇮🇩"), aliases: ["인도네시아", "Indonesia"]),
        .init(countryCode: "MY", name: "country.my", flagValue: .emoji("🇲🇾"), aliases: ["말레이시아", "Malaysia"]),
        .init(countryCode: "PH", name: "country.ph", flagValue: .emoji("🇵🇭"), aliases: ["필리핀", "Philippines"]),
        .init(countryCode: "ES", name: "country.es", flagValue: .emoji("🇪🇸"), aliases: ["스페인", "Spain"]),
        .init(countryCode: "IT", name: "country.it", flagValue: .emoji("🇮🇹"), aliases: ["이탈리아", "Italy"]),
        .init(countryCode: "NZ", name: "country.nz", flagValue: .emoji("🇳🇿"), aliases: ["뉴질랜드", "New Zealand"]),
        .init(countryCode: "MX", name: "country.mx", flagValue: .emoji("🇲🇽"), aliases: ["멕시코", "Mexico"]),
        .init(countryCode: "IN", name: "country.in", flagValue: .emoji("🇮🇳"), aliases: ["인도", "India"])
    ]
}
