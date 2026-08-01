import SwiftUI

struct MainTabView: View {
    @State private var selection: MainTab = .home
    let homeDashboardRepository: any HomeDashboardRepository
    let preparationTimelineRepository: any PreparationTimelineRepository
    let onLogout: () -> Void

    init(
        homeDashboardRepository: any HomeDashboardRepository,
        preparationTimelineRepository: any PreparationTimelineRepository,
        onLogout: @escaping () -> Void = {}
    ) {
        self.homeDashboardRepository = homeDashboardRepository
        self.preparationTimelineRepository = preparationTimelineRepository
        self.onLogout = onLogout
    }

    var body: some View {
        ZStack {
            NavigationStack {
                HomeDashboardView(
                    repository: homeDashboardRepository,
                    timelineRepository: preparationTimelineRepository
                )
            }
            .tabContentState(isSelected: selection == .home)

            NavigationStack {
                WriteExperienceHomeView()
            }
            .tabContentState(isSelected: selection == .writeDiscovery)

            NavigationStack {
                ProfileSettingsView(onLogout: onLogout)
            }
            .tabContentState(isSelected: selection == .more)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MainTabBar(selection: $selection)
                .padding(.horizontal, CBSpacing.medium)
                .padding(.bottom, CBSpacing.small)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private extension View {
    func tabContentState(isSelected: Bool) -> some View {
        opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
    }
}

enum MainTab: Hashable, CaseIterable {
    case home
    case writeDiscovery
    case more

    var title: LocalizedStringResource {
        switch self {
        case .home: "mainTab.home"
        case .writeDiscovery: "mainTab.writeDiscovery"
        case .more: "mainTab.more"
        }
    }

    var iconResource: ImageResource {
        switch self {
        case .home: .logo
        case .writeDiscovery: .tabWriteDiscovery
        case .more: .tabMore
        }
    }
}

#Preview {
    MainTabView(
        homeDashboardRepository: FixtureHomeDashboardRepository(),
        preparationTimelineRepository: FixturePreparationTimelineRepository()
    )
        .environment(\.locale, Locale(identifier: "ko"))
}
