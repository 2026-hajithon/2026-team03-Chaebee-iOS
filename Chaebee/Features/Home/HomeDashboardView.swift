import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel: HomeDashboardViewModel
    @State private var isEditingTrips = false
    @State private var pendingTripDeletion: HomeTripSummary?

    init(
        repository: (any HomeDashboardRepository)? = nil
    ) {
        let resolvedRepository = repository ?? FixtureHomeDashboardRepository()
        _viewModel = StateObject(
            wrappedValue: HomeDashboardViewModel(repository: resolvedRepository)
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
        .confirmationDialog(
            "home.deleteTrip.title",
            isPresented: Binding(
                get: { pendingTripDeletion != nil },
                set: { if !$0 { pendingTripDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("home.deleteTrip.confirm", role: .destructive) {
                guard let trip = pendingTripDeletion else { return }
                pendingTripDeletion = nil
                Task {
                    await viewModel.deleteTrip(id: trip.id)
                    if viewModel.dashboard?.trips.isEmpty == true {
                        isEditingTrips = false
                    }
                }
            }

            Button("common.cancel", role: .cancel) {
                pendingTripDeletion = nil
            }
        } message: {
            Text("home.deleteTrip.message")
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

                Button {
                    withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
                        isEditingTrips.toggle()
                    }
                } label: {
                    Text(editTripsTitle)
                        .cbTypography(.body2)
                        .foregroundStyle(isEditingTrips ? CBColor.blue5 : CBColor.gray6)
                }
                .buttonStyle(.plain)
            }

            if trips.count == 1, let trip = trips.first {
                tripCard(trip, layout: .single)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: CBSpacing.small),
                        GridItem(.flexible(), spacing: CBSpacing.small)
                    ],
                    spacing: CBSpacing.small
                ) {
                    ForEach(trips) { trip in
                        tripCard(trip, layout: .grid)
                    }
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

    private var editTripsTitle: LocalizedStringKey {
        isEditingTrips ? "common.done" : "home.editTrips"
    }

    @ViewBuilder
    private func tripCard(
        _ trip: HomeTripSummary,
        layout: HomeTripCard.Layout
    ) -> some View {
        if isEditingTrips {
            HomeTripCard(
                trip: trip,
                layout: layout,
                isEditing: true,
                onDelete: { pendingTripDeletion = trip }
            )
        } else {
            NavigationLink {
                TimelineHomeView(
                    tripID: trip.id,
                    repository: FixturePreparationTimelineRepository(
                        destination: trip.timelineDestination
                    )
                )
            } label: {
                HomeTripCard(trip: trip, layout: layout)
            }
            .buttonStyle(.plain)
        }
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

#Preview("Single Trip") {
    NavigationStack {
        HomeDashboardView(
            repository: FixtureHomeDashboardRepository(state: .singleTrip)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
