import SwiftUI

struct CitySelectionView: View {
    @ObservedObject private var registration: TripRegistrationViewModel

    @State private var selectedCity: City?
    @State private var showsDateSelection = false

    init(registration: TripRegistrationViewModel) {
        self.registration = registration
    }

    var body: some View {
        TripRegistrationStepLayout(
            title: "tripRegistration.citySelection.title.us",
            isNextEnabled: selectedCity != nil,
            onNext: { showsDateSelection = true }
        ) {
            VStack(spacing: CBSpacing.medium) {
                ForEach(City.allCases) { city in
                    CitySelectionButton(
                        name: city.name,
                        state: state(for: city),
                        action: { select(city) }
                    )
                }
            }
        }
        .navigationDestination(isPresented: $showsDateSelection) {
            DateSelectionView(registration: registration)
        }
    }

    private func select(_ city: City) {
        guard city.availability == .selectable else { return }
        selectedCity = city
        registration.selectCity(code: city.apiCode)
    }

    private func state(for city: City) -> CitySelectionButton.State {
        if selectedCity == city {
            return .selected
        }

        switch city.availability {
        case .selectable:
            return .selectable
        case .disabled:
            return .disabled
        case .comingSoon:
            return .comingSoon
        }
    }
}

private enum City: String, CaseIterable, Identifiable {
    case losAngeles
    case newYork
    case honolulu

    enum Availability: Equatable {
        case selectable
        case disabled
        case comingSoon
    }

    var id: String { rawValue }

    var apiCode: String {
        switch self {
        case .losAngeles: "LOS_ANGELES"
        case .newYork: "NEW_YORK"
        case .honolulu: "HONOLULU"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .losAngeles: "city.losAngeles"
        case .newYork: "city.newYork"
        case .honolulu: "city.honolulu"
        }
    }

    var availability: Availability {
        switch self {
        case .losAngeles, .newYork:
            .selectable
        case .honolulu:
            .comingSoon
        }
    }
}

#Preview {
    NavigationStack {
        CitySelectionView(registration: TripRegistrationViewModel())
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
