import SwiftUI

struct TimelineHomeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TimelineHomeViewModel

    init(
        tripID: Int = 12,
        repository: any PreparationTimelineRepository = FixturePreparationTimelineRepository()
    ) {
        _viewModel = StateObject(
            wrappedValue: TimelineHomeViewModel(
                tripID: tripID,
                repository: repository
            )
        )
    }

    var body: some View {
        Group {
            if let timeline = viewModel.timeline {
                timelineContent(timeline)
            } else if viewModel.isLoading {
                ProgressView()
                    .tint(CBColor.blue5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.errorMessage != nil {
                errorView
            } else {
                Color.clear
            }
        }
        .background(CBColor.gray1)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    private func timelineContent(_ timeline: PreparationTimeline) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                backButton

                destinationHeader(timeline)
                    .padding(.top, CBSpacing.medium)

                TimelineSummaryCards(
                    progress: timeline.progress,
                    highlight: timeline.highlight
                )
                .padding(.top, CBSpacing.medium)

                Text("timeline.title")
                    .cbTypography(.head3)
                    .foregroundStyle(CBColor.gray9)
                    .padding(.top, CBSpacing.large)
                    .padding(.bottom, CBSpacing.medium)

                VStack(spacing: 0) {
                    if timeline.phases.isEmpty {
                        Text("timeline.empty.title")
                            .cbTypography(.body2)
                            .foregroundStyle(CBColor.gray6)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CBSpacing.xLarge)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
                    } else {
                        ForEach(Array(timeline.phases.enumerated()), id: \.element.id) { index, phase in
                            TimelinePhaseRow(
                                phase: phase,
                                showsTrailingLine: index < timeline.phases.count - 1,
                                onToggle: viewModel.toggleChecklistItem
                            )
                        }
                    }
                }

                TimelineEssentialInfoSection(info: timeline.essentialInfo)
                    .padding(.top, CBSpacing.small)
                    .padding(.bottom, CBSpacing.xLarge)
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.medium)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.retry()
        }
    }

    private func destinationHeader(_ timeline: PreparationTimeline) -> some View {
        HStack(spacing: CBSpacing.small) {
            Text(verbatim: timeline.destinationName)
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray9)

            Text(verbatim: "D-\(timeline.dDay)")
                .cbTypography(.subhead1)
                .foregroundStyle(Color.white)
                .padding(.horizontal, CBSpacing.small)
                .frame(height: 24)
                .background(CBColor.blue5)
                .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(CBColor.gray9)
                .frame(width: 44, height: 44)
                .background(Color.white, in: Circle())
                .shadow(
                    color: CBShadow.subtle.color,
                    radius: CBShadow.subtle.radius,
                    x: CBShadow.subtle.x,
                    y: CBShadow.subtle.y
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("common.back"))
    }

    private var errorView: some View {
        VStack(spacing: CBSpacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(CBColor.gray5)

            Text("timeline.error.title")
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

#Preview("Singapore") {
    NavigationStack {
        TimelineHomeView(
            repository: FixturePreparationTimelineRepository(destination: .singapore)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("Los Angeles") {
    NavigationStack {
        TimelineHomeView(
            repository: FixturePreparationTimelineRepository(destination: .losAngeles)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}

#Preview("Taiwan") {
    NavigationStack {
        TimelineHomeView(
            repository: FixturePreparationTimelineRepository(destination: .taiwan)
        )
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
