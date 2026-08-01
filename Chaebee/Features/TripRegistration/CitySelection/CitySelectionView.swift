import SwiftUI

struct CitySelectionView: View {
    @State private var selectedCity: City?
    @State private var showsDateSelection = false

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
                        action: { selectedCity = city }
                    )
                }
            }
        }
        .navigationDestination(isPresented: $showsDateSelection) {
            DateSelectionView()
        }
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

    enum Availability {
        case selectable
        case disabled
        case comingSoon
    }

    var id: String { rawValue }

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
        CitySelectionView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
