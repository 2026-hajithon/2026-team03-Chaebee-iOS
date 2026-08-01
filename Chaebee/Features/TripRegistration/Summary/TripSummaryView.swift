import SwiftUI

struct TripSummaryView: View {
    @ObservedObject private var registration: TripRegistrationViewModel

    init(registration: TripRegistrationViewModel) {
        self.registration = registration
    }

    var body: some View {
        Text("Trip Summary")
    }
}

#Preview {
    TripSummaryView(registration: TripRegistrationViewModel())
}
