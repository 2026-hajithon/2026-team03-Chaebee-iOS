import SwiftUI

struct RootView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    RootView()
        .environment(\.locale, Locale(identifier: "ko"))
}
