import SwiftUI

struct RootView: View {
    @AppStorage("chaebee.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("chaebee.isLoggedIn") private var isLoggedIn = false
    @State private var hasResolvedLaunchState = false

    var body: some View {
        Group {
            if !hasResolvedLaunchState {
                CBColor.gray1
                    .ignoresSafeArea()
            } else if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingFlowView { authenticated in
                    withAnimation(.easeInOut(duration: CBAnimation.standardDuration)) {
                        isLoggedIn = authenticated
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            guard !hasResolvedLaunchState else { return }

            // Guest access is valid only for the current app session.
            // A relaunch without an authenticated session starts from WelcomeView.
            if !isLoggedIn {
                hasCompletedOnboarding = false
            }
            hasResolvedLaunchState = true
        }
    }
}

#Preview {
    RootView()
        .environment(\.locale, Locale(identifier: "ko"))
}
