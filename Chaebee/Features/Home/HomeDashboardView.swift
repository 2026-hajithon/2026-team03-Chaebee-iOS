import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel: HomeDashboardViewModel

    init(
        repository: any HomeDashboardRepository = FixtureHomeDashboardRepository()
    ) {
        _viewModel = StateObject(
            wrappedValue: HomeDashboardViewModel(repository: repository)
        )
    }

    var body: some View {
        Group {
            if let dashboard = viewModel.dashboard {
                dashboardContent(dashboard)
            } else if viewModel.isLoading {
                ProgressView()
                    .tint(CBColor.blue5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView
            }
        }
        .background(CBColor.gray1)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    private func dashboardContent(_ dashboard: HomeDashboard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                homeHeader

                if dashboard.hasRegisteredTrip {
                    registeredTripsSection(dashboard.trips)
                } else {
                    EmptyTripCard()
                        .padding(.top, CBSpacing.large)
                }

                discoverySection(dashboard.editorDiscoveries)
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.medium)
            .padding(.bottom, CBSpacing.xLarge)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.retry()
        }
    }

    private var homeHeader: some View {
        HStack {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 44, alignment: .leading)

            Spacer()

            Image(systemName: "bell.fill")
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(CBColor.gray4)
                .frame(width: 44, height: 44)
            .accessibilityLabel(Text("home.notifications"))
        }
    }

    private func registeredTripsSection(_ trips: [HomeTripSummary]) -> some View {
        VStack(spacing: CBSpacing.medium) {
            HStack {
                Label("home.sortByDate", systemImage: "arrow.up.arrow.down")
                    .cbTypography(.body2)
                    .foregroundStyle(CBColor.gray6)

                Spacer()

                Text("home.editTrips")
                    .cbTypography(.body2)
                    .foregroundStyle(CBColor.gray6)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: CBSpacing.small),
                    GridItem(.flexible(), spacing: CBSpacing.small)
                ],
                spacing: CBSpacing.small
            ) {
                ForEach(trips) { trip in
                    NavigationLink {
                        TimelineHomeView(
                            tripID: trip.id,
                            repository: FixturePreparationTimelineRepository(
                                destination: trip.timelineDestination
                            )
                        )
                    } label: {
                        HomeTripCard(trip: trip)
                    }
                    .buttonStyle(.plain)
                }
            }

            NavigationLink {
                TripRegistrationFlowView()
            } label: {
                Text("home.addTrip")
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.blue5)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(CBColor.blue1)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, CBSpacing.medium)
    }

    private func discoverySection(
        _ discoveries: [HomeDiscoverySummary]
    ) -> some View {
        VStack(alignment: .leading, spacing: CBSpacing.medium) {
            Text("home.editorDiscoveries")
                .cbTypography(.head5)
                .foregroundStyle(CBColor.gray9)

            ForEach(discoveries) { discovery in
                HomeDiscoveryCard(discovery: discovery)
            }
        }
        .padding(.top, CBSpacing.xLarge)
    }

    private var errorView: some View {
        VStack(spacing: CBSpacing.medium) {
            Text("home.error.title")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray8)

            CBButton("timeline.error.retry") {
                Task { await viewModel.retry() }
            }
        }
        .padding(CBSpacing.pageHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Registered") {
    NavigationStack {
        HomeDashboardView(
            repository: FixtureHomeDashboardRepository(state: .registered)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("Empty") {
    NavigationStack {
        HomeDashboardView(
            repository: FixtureHomeDashboardRepository(state: .empty)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
