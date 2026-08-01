import SwiftUI
import GoogleSignIn

struct RootView: View {
    @AppStorage("chaebee.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("chaebee.isLoggedIn") private var isLoggedIn = false
    @State private var hasResolvedLaunchState = false
    private let environment: AppEnvironment

    init(environment: AppEnvironment = .live()) {
        self.environment = environment
    }

    var body: some View {
        Group {
            if !hasResolvedLaunchState {
                CBColor.gray1
                    .ignoresSafeArea()
            } else if hasCompletedOnboarding {
                MainTabView(
                    homeDashboardRepository: environment.homeDashboardRepository,
                    preparationTimelineRepository: environment.preparationTimelineRepository,
                    writeExperienceRepository: environment.writeExperienceRepository,
                    myDiscoveriesRepository: environment.myDiscoveriesRepository,
                    experienceLocationRepository: environment.experienceLocationRepository,
                    onLogout: logout
                )
                    .transition(.opacity)
            } else {
                OnboardingFlowView(
                    authenticationRepository: environment.authenticationRepository,
                    googleSignInService: GoogleSignInService()
                ) { authenticated in
                    withAnimation(.easeInOut(duration: CBAnimation.standardDuration)) {
                        isLoggedIn = authenticated
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .environment(
            \.tripRegistrationRepository,
            environment.tripRegistrationRepository
        )
        .task {
            guard !hasResolvedLaunchState else { return }

            let hasStoredSession = (try? await environment.authTokenStore.tokens()) != nil
            if isLoggedIn, !hasStoredSession {
                isLoggedIn = false
                hasCompletedOnboarding = false
            } else if !isLoggedIn {
                // Guest access is valid only for the current app session.
                hasCompletedOnboarding = false
                try? await environment.authTokenStore.clear()
            }
            hasResolvedLaunchState = true
        }
    }

    private func logout() {
        Task {
            try? await environment.authTokenStore.clear()
            GIDSignIn.sharedInstance.signOut()
            withAnimation(.easeInOut(duration: CBAnimation.standardDuration)) {
                isLoggedIn = false
                hasCompletedOnboarding = false
            }
        }
    }
}

#Preview {
    RootView()
        .environment(\.locale, Locale(identifier: "ko"))
}
