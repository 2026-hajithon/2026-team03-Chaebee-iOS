import SwiftUI

struct WriteExperienceInputView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = WriteExperienceInputViewModel()
    @State private var locationText = ""
    @State private var showsLocationSearch = false
    @State private var discoveryEditorRoute: DiscoveryEditorRoute?
    @State private var showsLimitToast = false

    private let onSubmit: (WriteExperienceRequest) -> Void

    init(onSubmit: @escaping (WriteExperienceRequest) -> Void = { _ in }) {
        self.onSubmit = onSubmit
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                WriteExperienceNavigationHeader(
                    isNextEnabled: viewModel.canProceed,
                    actionTitle: "writeExperience.input.submit",
                    onClose: { dismiss() },
                    onNext: proceed
                )

                locationSection
                    .padding(.top, CBSpacing.large)

                travelTypeSection
                    .padding(.top, CBSpacing.medium)

                discoverySection
                    .padding(.top, CBSpacing.medium)
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.medium)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(CBColor.gray1)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsLocationSearch) {
            ExperienceLocationSearchView { location in
                viewModel.selectLocation(location)
                locationText = locationDisplayName(location)
            }
        }
        .sheet(item: $discoveryEditorRoute) { route in
            TagSelectionView(discovery: route.discovery) { discovery in
                if route.discovery?.id == discovery.id {
                    viewModel.updateDiscovery(discovery)
                } else {
                    let didAddDiscovery = viewModel.addDiscovery(discovery)
                    if !didAddDiscovery || viewModel.hasReachedDiscoveryLimit {
                        showLimitToast()
                    }
                }
            }
            .presentationDragIndicator(.visible)
        }
        .overlay(alignment: .bottom) {
            if showsLimitToast {
                limitToast
                    .padding(.horizontal, CBSpacing.pageHorizontal)
                    .padding(.bottom, CBSpacing.large)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }

    private var locationSection: some View {
        formRow(title: "writeExperience.input.location") {
            CBTextField(
                text: $locationText,
                placeholder: "writeExperience.location.placeholder",
                trailingSystemImage: "magnifyingglass",
                onTrailingTap: { showsLocationSearch = true }
            )
            .onTapGesture { showsLocationSearch = true }
        }
    }

    private var travelTypeSection: some View {
        formRow(title: "writeExperience.input.travelType", alignment: .top) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: CBSpacing.small),
                    GridItem(.flexible(), spacing: CBSpacing.small)
                ],
                spacing: CBSpacing.small
            ) {
                ForEach(ExperienceTravelType.allCases) { travelType in
                    CBSelectionButton(
                        title: travelType.localizedName,
                        state: travelTypeState(travelType),
                        action: { viewModel.selectTravelType(travelType) }
                    )
                }
            }
        }
    }

    private var discoverySection: some View {
        formRow(title: "writeExperience.input.discoveries", alignment: .top) {
            VStack(alignment: .leading, spacing: CBSpacing.small) {
                ForEach(viewModel.draft.discoveries) { discovery in
                    ExperienceDraftDiscoveryCard(
                        discovery: discovery,
                        onEdit: {
                            discoveryEditorRoute = DiscoveryEditorRoute(
                                discovery: discovery
                            )
                        },
                        onDelete: {
                            withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
                                viewModel.removeDiscovery(id: discovery.id)
                            }
                        }
                    )
                }

                Button(action: addDiscovery) {
                    Label(
                        "writeExperience.discovery.add",
                        systemImage: "plus"
                    )
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.blue5)
                    .padding(.horizontal, CBSpacing.small)
                    .frame(height: 36)
                    .background(CBColor.gray2)
                    .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
                }
                .buttonStyle(.plain)
            }
            .padding(CBSpacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.medium)
                    .strokeBorder(CBColor.gray3, lineWidth: 1)
            }
        }
    }

    private func formRow<Content: View>(
        title: LocalizedStringResource,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: alignment, spacing: CBSpacing.small) {
            Text(title)
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray8)
                .frame(width: 72, alignment: .leading)
                .padding(.top, alignment == .top ? 14 : 0)

            content()
                .frame(maxWidth: .infinity)
        }
    }

    private func travelTypeState(
        _ travelType: ExperienceTravelType
    ) -> CBSelectionButton.State {
        viewModel.draft.travelType == travelType ? .selected : .selectable
    }

    private var limitToast: some View {
        HStack(spacing: CBSpacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(CBColor.yellow)

            Text("writeExperience.discovery.limit")
                .cbTypography(.body4)
                .foregroundStyle(Color.white)

            Spacer()
        }
        .padding(.horizontal, CBSpacing.medium)
        .frame(height: 56)
        .background(CBColor.gray5)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
    }

    private func addDiscovery() {
        if viewModel.hasReachedDiscoveryLimit {
            showLimitToast()
        } else {
            discoveryEditorRoute = DiscoveryEditorRoute(discovery: nil)
        }
    }

    private func showLimitToast() {
        withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
            showsLimitToast = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation(.easeOut(duration: CBAnimation.quickDuration)) {
                    showsLimitToast = false
                }
            }
        }
    }

    private func proceed() {
        guard let request = viewModel.makeRequest() else { return }
        onSubmit(request)
        dismiss()
    }

    private func locationDisplayName(_ location: ExperienceLocation) -> String {
        let countryName = String(localized: location.country.localizedName)
        return "\(location.cityName), \(countryName)"
    }
}

private struct DiscoveryEditorRoute: Identifiable {
    let id = UUID()
    let discovery: ExperienceDraftDiscovery?
}

#Preview {
    NavigationStack {
        WriteExperienceInputView()
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
