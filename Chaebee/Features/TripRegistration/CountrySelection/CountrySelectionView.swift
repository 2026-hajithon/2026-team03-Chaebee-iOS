import SwiftUI

struct CountrySelectionView: View {
    @State private var selectedCountry: Country?
    @State private var showsCitySelection = false
    @State private var showsDateSelection = false

    var body: some View {
        TripRegistrationStepLayout(
            title: "tripRegistration.countrySelection.title",
            isNextEnabled: selectedCountry != nil,
            onNext: proceedToNextStep
        ) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(Country.allCases) { country in
                    CountrySelectionCard(
                        name: country.name,
                        flag: country.flag,
                        state: state(for: country),
                        action: { select(country) }
                    )
                }
            }
        }
        .navigationDestination(isPresented: $showsCitySelection) {
            CitySelectionView()
        }
        .navigationDestination(isPresented: $showsDateSelection) {
            DateSelectionView()
        }
    }

    private func state(for country: Country) -> CountrySelectionCard.State {
        if selectedCountry == country {
            return .selected
        }

        switch country.availability {
        case .citySelection, .countrySelection:
            return .selectable
        case .comingSoon:
            return .comingSoon
        }
    }

    private func select(_ country: Country) {
        switch country.availability {
        case .citySelection:
            selectedCountry = country
            showsCitySelection = true
        case .countrySelection:
            selectedCountry = country
        case .comingSoon:
            break
        }
    }

    private func proceedToNextStep() {
        guard let selectedCountry else { return }

        if selectedCountry.availability == .citySelection {
            showsCitySelection = true
        } else {
            showsDateSelection = true
        }
    }
}

private enum Country: String, CaseIterable, Identifiable {
    case us
    case tw
    case sg
    case jp
    case br
    case au
    case th
    case vn
    case hk
    case fr
    case uk
    case de

    enum Availability: Equatable {
        case citySelection
        case countrySelection
        case comingSoon
    }

    var id: String { rawValue }

    var name: LocalizedStringResource {
        switch self {
        case .us: "country.us"
        case .tw: "country.tw"
        case .sg: "country.sg"
        case .jp: "country.jp"
        case .br: "country.br"
        case .au: "country.au"
        case .th: "country.th"
        case .vn: "country.vn"
        case .hk: "country.hk"
        case .fr: "country.fr"
        case .uk: "country.uk"
        case .de: "country.de"
        }
    }

    var flag: ImageResource {
        switch self {
        case .us: .flagUS
        case .tw: .flagTW
        case .sg: .flagSG
        case .jp: .flagJP
        case .br: .flagBR
        case .au: .flagAU
        case .th: .flagTH
        case .vn: .flagVN
        case .hk: .flagHK
        case .fr: .flagFR
        case .uk: .flagUK
        case .de: .flagDE
        }
    }

    var availability: Availability {
        switch self {
        case .us:
            .citySelection
        case .tw, .sg:
            .countrySelection
        case .jp, .br, .au, .th, .vn, .hk, .fr, .uk, .de:
            .comingSoon
        }
    }
}

#Preview {
    NavigationStack {
        CountrySelectionView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
