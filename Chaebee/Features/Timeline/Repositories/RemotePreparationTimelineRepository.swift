import Foundation

struct RemotePreparationTimelineRepository: PreparationTimelineRepository {
    let client: any APIClient

    func fetchTimeline(tripID: Int) async throws -> PreparationTimeline {
        let response: APIResponseDTO<TimelineResponseDTO> = try await client.request(
            TimelineEndpoint.timeline(tripID: tripID),
            as: APIResponseDTO<TimelineResponseDTO>.self
        )
        return map(response.data, tripID: tripID)
    }

    func updateChecklistItem(id: Int, isChecked: Bool) async throws {
        try await client.request(
            TimelineEndpoint.updateChecklistItem(id: id, isChecked: isChecked)
        )
    }

    private func map(
        _ response: TimelineResponseDTO,
        tripID: Int
    ) -> PreparationTimeline {
        let phases = response.timeline.enumerated().map { phaseIndex, phase in
            TimelinePhase(
                id: "\(phase.dDay)-\(phase.date)-\(phaseIndex)",
                label: dayLabel(phase.dDay),
                date: date(from: phase.date),
                isCurrent: phase.dDay == response.tripInfo.dDay,
                discoveries: phase.discoveries.enumerated().map { discoveryIndex, discovery in
                    TimelineDiscovery(
                        id: phaseIndex * 10_000 + discoveryIndex,
                        tag: discovery.tag,
                        title: discovery.title,
                        content: discovery.content
                    )
                },
                checklistItems: phase.checklists.map {
                    TimelineChecklistItem(
                        id: $0.checklistID,
                        tag: $0.tag,
                        title: $0.title,
                        isChecked: $0.isChecked,
                        actionTitle: nil,
                        actionURL: nil
                    )
                }
            )
        }
        let highlightedItem = response.timeline
            .flatMap(\.checklists)
            .first(where: { !$0.isChecked })
            ?? response.timeline.flatMap(\.checklists).first
        let progressTotal = max(0, response.tripInfo.progress.total)
        let progressCompleted = min(
            max(0, response.tripInfo.progress.completed),
            progressTotal
        )
        let essentialInfo = response.essentialInfo

        return PreparationTimeline(
            id: tripID,
            destinationName: response.tripInfo.destination,
            dDay: response.tripInfo.dDay,
            progress: TimelineProgress(
                done: progressCompleted,
                total: progressTotal
            ),
            highlight: TimelineHighlight(
                tag: highlightedItem?.tag ?? .passport,
                title: highlightedItem?.title ?? "",
                subtitle: String(localized: "timeline.highlight.recommendedNow")
            ),
            phases: phases,
            essentialInfo: TimelineEssentialInfo(
                passportValidityRule: essentialInfo.passportValidityRule,
                visaFreeStayDescription: String(
                    format: String(localized: "timeline.essentialInfo.visaFreeStayDays"),
                    essentialInfo.visaFreeStayDays
                ),
                officialSiteName: essentialInfo.officialSiteURL.host()
                    ?? response.tripInfo.destination,
                officialSiteURL: essentialInfo.officialSiteURL,
                lastUpdatedDescription: formattedDate(essentialInfo.lastUpdatedAt)
            )
        )
    }

    private func dayLabel(_ dDay: Int) -> String {
        if dDay == 0 { return "D-Day" }
        return "D-\(abs(dDay))"
    }

    private func date(from value: String) -> Date {
        Self.dateFormatter.date(from: value) ?? Date.distantPast
    }

    private func formattedDate(_ value: String) -> String {
        guard let date = Self.dateFormatter.date(from: value) else { return value }
        return date.formatted(.dateTime.year().month().day())
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
