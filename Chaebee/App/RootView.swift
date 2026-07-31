import SwiftUI

/// Development-only entry list for verifying feature placeholder screens.
/// Pre-hackathon scaffolding, not the real app navigation.
/// Replace with the real navigation (AppRouter) after the hackathon starts.
struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Onboarding") {
                    NavigationLink("Welcome") { WelcomeView() }
                    NavigationLink("Notification Permission") { NotificationPermissionView() }
                    NavigationLink("Passport Guide") { PassportGuideView() }
                    NavigationLink("Passport Selection") { PassportSelectionView() }
                    NavigationLink("Complete") { OnboardingCompleteView() }
                }
                Section("Trip Registration") {
                    NavigationLink("Country Selection") { CountrySelectionView() }
                    NavigationLink("Date Selection") { DateSelectionView() }
                    NavigationLink("Interest Selection") { InterestSelectionView() }
                    NavigationLink("Summary") { TripSummaryView() }
                }
                Section("Timeline") {
                    NavigationLink("Home") { TimelineHomeView() }
                    NavigationLink("Preparation Detail") { PreparationDetailView() }
                    NavigationLink("Official Info") { OfficialInfoView() }
                    NavigationLink("Experience Tips") { ExperienceTipsView() }
                }
                Section("Discovery") {
                    NavigationLink("Feed") { DiscoveryFeedView() }
                    NavigationLink("Detail") { DiscoveryDetailView() }
                }
                Section("Write Experience") {
                    NavigationLink("Input") { WriteExperienceInputView() }
                    NavigationLink("Tag Selection") { TagSelectionView() }
                    NavigationLink("Preview") { ExperiencePreviewView() }
                    NavigationLink("Complete") { WriteExperienceCompleteView() }
                }
                Section("Profile") {
                    NavigationLink("My Trips") { MyTripsView() }
                    NavigationLink("My Experiences") { MyExperiencesView() }
                    NavigationLink("Settings") { ProfileSettingsView() }
                    NavigationLink("About") { AboutView() }
                }
            }
            .navigationTitle("Chaebee")
        }
    }
}
