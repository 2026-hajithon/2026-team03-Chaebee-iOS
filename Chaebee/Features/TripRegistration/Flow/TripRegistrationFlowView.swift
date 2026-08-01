import SwiftUI

struct TripRegistrationFlowView: View {
    @StateObject private var viewModel = TripRegistrationViewModel()

    var body: some View {
        CountrySelectionView(registration: viewModel)
    }
}

#Preview {
    NavigationStack {
        TripRegistrationFlowView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
