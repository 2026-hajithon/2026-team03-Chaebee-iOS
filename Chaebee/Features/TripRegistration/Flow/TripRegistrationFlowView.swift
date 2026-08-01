import SwiftUI

struct TripRegistrationFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TripRegistrationViewModel()

    var body: some View {
        CountrySelectionView(registration: viewModel)
            .onChange(of: viewModel.registeredTrip?.id) { _, tripID in
                guard tripID != nil else { return }
                dismiss()
            }
    }
}

#Preview {
    NavigationStack {
        TripRegistrationFlowView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
