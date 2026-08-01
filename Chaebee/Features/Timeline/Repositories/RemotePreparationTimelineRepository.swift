import Foundation

struct TimelinePresentationContext: Sendable {
    let destinationName: String
    let countryCode: String
    let dDay: Int
    let departureDate: Date
}

struct RemotePreparationTimelineRepository: PreparationTimelineRepository {
    let client: any APIClient
    let context: TimelinePresentationContext

    func fetchTimeline(tripID: Int) async throws -> PreparationTimeline {
        let timelineEnvelope: APIResponseDTO<TimelineResponseDTO> = try await client.request(
            TimelineEndpoint.timeline(tripID: tripID),
            as: APIResponseDTO<TimelineResponseDTO>.self
        )
        let essentialInfoEnvelope: APIResponseDTO<EssentialInfoResponseDTO> = try await client.request(
            TimelineEndpoint.essentialInfo(countryCode: context.countryCode),
            as: APIResponseDTO<EssentialInfoResponseDTO>.self
        )
        return map(
            timeline: timelineEnvelope.data,
            essentialInfo: essentialInfoEnvelope.data
        )
    }

    func updateChecklistItem(id: Int, isChecked: Bool) async throws {
        _ = try await client.request(
            TimelineEndpoint.updateChecklistItem(id: id, isChecked: isChecked),
            as: APIResponseDTO<EmptyResponseDTO?>.self
        )
    }

    private func map(
        timeline: TimelineResponseDTO,
        essentialInfo: EssentialInfoResponseDTO
    ) -> PreparationTimeline {
        let phases = timeline.phases.enumerated().map { index, phase in
            TimelinePhase(
                id: "\(phase.phaseLabel)-\(index)",
                label: phase.phaseLabel,
                date: date(for: phase.phaseLabel),
                isCurrent: index == 0,
                discoveries: phase.subDiscoveries.map {
                    TimelineDiscovery(
                        id: $0.subDiscoveryID,
                        tag: $0.tag,
                        content: $0.content
                    )
                },
                checklistItems: phase.checklistItems.map {
                    TimelineChecklistItem(
                        id: $0.checklistItemID,
                        tag: $0.tag,
                        title: $0.title,
                        isChecked: $0.isChecked,
                        actionTitle: nil,
                        actionURL: nil
                    )
                }
            )
        }
        let highlightedItem = timeline.phases
            .flatMap(\.checklistItems)
            .first(where: { !$0.isChecked })
            ?? timeline.phases.flatMap(\.checklistItems).first

        let progressTotal = max(0, timeline.progress.total)
        let progressDone = min(max(0, timeline.progress.done), progressTotal)

        return PreparationTimeline(
            id: timeline.tripID,
            destinationName: context.destinationName,
            countryCode: context.countryCode,
            dDay: context.dDay,
            progress: TimelineProgress(
                done: progressDone,
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
                officialSiteName: essentialInfo.officialSiteURL.host() ?? context.countryCode,
                officialSiteURL: essentialInfo.officialSiteURL,
                lastUpdatedDescription: formattedDate(essentialInfo.lastUpdatedAt)
            )
        )
    }

    private func date(for phaseLabel: String) -> Date {
        guard phaseLabel.hasPrefix("D-") else { return context.departureDate }
        let dayText = phaseLabel.dropFirst(2)
        guard let daysBeforeDeparture = Int(dayText) else { return context.departureDate }
        return Calendar.current.date(
            byAdding: .day,
            value: -daysBeforeDeparture,
            to: context.departureDate
        ) ?? context.departureDate
    }

    private func formattedDate(_ value: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: value) else { return value }
        return date.formatted(.dateTime.year().month().day())
    }
}

private struct EmptyResponseDTO: Decodable {}
