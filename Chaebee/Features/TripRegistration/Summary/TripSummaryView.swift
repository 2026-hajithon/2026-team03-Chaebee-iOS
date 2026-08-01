import SwiftUI

struct TripSummaryView: View {
    let options: TripRegistrationOptions?

    init(options: TripRegistrationOptions? = nil) {
        self.options = options
    }

    var body: some View {
        Text("Trip Summary")
    }
}

#Preview {
    TripSummaryView()
}
