import Foundation

struct FixturePreparationTimelineRepository: PreparationTimelineRepository {
    enum Destination: Sendable {
        case losAngeles
        case newYork
        case singapore
        case taiwan
    }

    let destination: Destination

    init(destination: Destination = .singapore) {
        self.destination = destination
    }

    func fetchTimeline(tripID: Int) async throws -> PreparationTimeline {
        switch destination {
        case .losAngeles:
            return makeUSATimeline(tripID: tripID, destinationName: "로스앤젤레스, 미국")
        case .newYork:
            return makeUSATimeline(tripID: tripID, destinationName: "뉴욕, 미국")
        case .singapore:
            return makeSingaporeTimeline(tripID: tripID)
        case .taiwan:
            return makeTaiwanTimeline(tripID: tripID)
        }
    }

    func updateChecklistItem(id: Int, isChecked: Bool) async throws {}

    private func makeUSATimeline(
        tripID: Int,
        destinationName: String
    ) -> PreparationTimeline {
        PreparationTimeline(
            id: tripID,
            destinationName: destinationName,
            countryCode: "USA",
            dDay: 30,
            progress: TimelineProgress(done: 4, total: 12),
            highlight: TimelineHighlight(
                tag: .visa,
                title: "ESTA 신청",
                subtitle: "지금 하면 좋아요"
            ),
            phases: [
                phase(
                    id: "usa-d30",
                    label: "D-30",
                    daysFromNow: 0,
                    isCurrent: true,
                    discoveries: [
                        discovery(1, .passport, "여권 유효기간은 체류기간 동안 유효하면 되지만, 여유 있게 확인해 두세요."),
                        discovery(2, .visa, "ESTA 신청은 공식 사이트인지 주소를 반드시 확인하세요.")
                    ],
                    items: [
                        item(101, .passport, "여권 준비", true),
                        item(
                            102,
                            .visa,
                            "ESTA 신청",
                            false,
                            actionTitle: "바로가기",
                            actionURL: "https://esta.cbp.dhs.gov"
                        )
                    ]
                ),
                commonInsurancePhase(prefix: "usa", startID: 110),
                commonConnectivityPhase(prefix: "usa", startID: 120, adapterTitle: "A/B타입 어댑터 준비"),
                commonDeparturePhase(prefix: "usa", startID: 130),
                commonArrivalPhase(prefix: "usa", startID: 140)
            ],
            essentialInfo: TimelineEssentialInfo(
                passportValidityRule: "체류기간 동안 유효해야 함",
                visaFreeStayDescription: "90일 까지",
                officialSiteName: "U.S. CBP",
                officialSiteURL: URL(string: "https://www.cbp.gov")!,
                lastUpdatedDescription: "이번 달"
            )
        )
    }

    private func makeSingaporeTimeline(tripID: Int) -> PreparationTimeline {
        PreparationTimeline(
            id: tripID,
            destinationName: "싱가포르",
            countryCode: "SINGAPORE",
            dDay: 30,
            progress: TimelineProgress(done: 4, total: 12),
            highlight: TimelineHighlight(
                tag: .passport,
                title: "여권 유효기간 확인",
                subtitle: "지금 하면 좋아요"
            ),
            phases: [
                phase(
                    id: "sg-d30",
                    label: "D-30",
                    daysFromNow: 0,
                    isCurrent: true,
                    discoveries: [
                        discovery(201, .passport, "긴급여권은 재사용이 안 될 수 있어요. 출국 전에 유효기간을 확인하세요.")
                    ],
                    items: [item(201, .passport, "여권 준비", true)]
                ),
                commonInsurancePhase(prefix: "sg", startID: 210),
                commonConnectivityPhase(prefix: "sg", startID: 220, adapterTitle: "G타입 어댑터 준비"),
                phase(
                    id: "sg-d3",
                    label: "D-3",
                    daysFromNow: 27,
                    discoveries: [
                        discovery(204, .entryForm, "SGAC는 입국 전 온라인으로 미리 제출할 수 있어요.")
                    ],
                    items: [
                        item(
                            231,
                            .entryForm,
                            "SGAC 제출",
                            false,
                            actionTitle: "바로가기",
                            actionURL: "https://eservices.ica.gov.sg/sgarrivalcard"
                        )
                    ]
                ),
                commonDeparturePhase(prefix: "sg", startID: 240),
                commonArrivalPhase(prefix: "sg", startID: 250)
            ],
            essentialInfo: TimelineEssentialInfo(
                passportValidityRule: "6개월 이상",
                visaFreeStayDescription: "90일 까지",
                officialSiteName: "ICA Singapore",
                officialSiteURL: URL(string: "https://www.ica.gov.sg")!,
                lastUpdatedDescription: "이번 달"
            )
        )
    }

    private func makeTaiwanTimeline(tripID: Int) -> PreparationTimeline {
        var timeline = makeSingaporeTimeline(tripID: tripID)
        timeline = PreparationTimeline(
            id: timeline.id,
            destinationName: "대만",
            countryCode: "TAIWAN",
            dDay: timeline.dDay,
            progress: timeline.progress,
            highlight: timeline.highlight,
            phases: timeline.phases.map { phase in
                guard phase.id == "sg-d3" else { return phase }
                return TimelinePhase(
                    id: "tw-d3",
                    label: phase.label,
                    date: phase.date,
                    isCurrent: phase.isCurrent,
                    discoveries: [
                        discovery(304, .entryForm, "TWAC는 입국 전 공식 사이트에서 제출할 수 있어요.")
                    ],
                    checklistItems: [
                        item(
                            331,
                            .entryForm,
                            "TWAC 제출",
                            false,
                            actionTitle: "바로가기",
                            actionURL: "https://twac.immigration.gov.tw"
                        )
                    ]
                )
            },
            essentialInfo: TimelineEssentialInfo(
                passportValidityRule: "6개월 이상",
                visaFreeStayDescription: "90일 까지",
                officialSiteName: "NIA, R.O.C. (Taiwan)",
                officialSiteURL: URL(string: "https://www.immigration.gov.tw")!,
                lastUpdatedDescription: "이번 달"
            )
        )
        return timeline
    }

    private func commonInsurancePhase(prefix: String, startID: Int) -> TimelinePhase {
        phase(
            id: "\(prefix)-d14",
            label: "D-14",
            daysFromNow: 16,
            discoveries: [
                discovery(startID, .insurance, "여행자 보험은 보장 범위와 자기부담금을 함께 확인하세요."),
                discovery(startID + 1, .transitCard, "교통카드는 도착 후 구매 가능한지도 미리 확인해 보세요.")
            ],
            items: [
                item(startID, .insurance, "보험 가입", true),
                item(startID + 1, .exchange, "환전", false),
                item(startID + 2, .transitCard, "교통카드 준비", false)
            ]
        )
    }

    private func commonConnectivityPhase(
        prefix: String,
        startID: Int,
        adapterTitle: String
    ) -> TimelinePhase {
        phase(
            id: "\(prefix)-d7",
            label: "D-7",
            daysFromNow: 23,
            discoveries: [
                discovery(startID, .adapter, "현지 콘센트 규격과 전압을 미리 확인하세요.")
            ],
            items: [
                item(startID, .adapter, adapterTitle, false),
                item(startID + 1, .esimRoaming, "eSIM 구매 및 설정", false)
            ]
        )
    }

    private func commonDeparturePhase(prefix: String, startID: Int) -> TimelinePhase {
        phase(
            id: "\(prefix)-d1",
            label: "D-1",
            daysFromNow: 29,
            items: [item(startID, .flightBoarding, "온라인 체크인", false)]
        )
    }

    private func commonArrivalPhase(prefix: String, startID: Int) -> TimelinePhase {
        phase(
            id: "\(prefix)-arrival",
            label: "도착",
            daysFromNow: 30,
            discoveries: [
                discovery(startID, .localAirport, "공항에서 숙소까지 이동 수단을 미리 저장해 두세요.")
            ],
            items: [item(startID, .localAirport, "입국심사", false)]
        )
    }

    private func phase(
        id: String,
        label: String,
        daysFromNow: Int,
        isCurrent: Bool = false,
        discoveries: [TimelineDiscovery] = [],
        items: [TimelineChecklistItem]
    ) -> TimelinePhase {
        TimelinePhase(
            id: id,
            label: label,
            date: Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date(),
            isCurrent: isCurrent,
            discoveries: discoveries,
            checklistItems: items
        )
    }

    private func discovery(
        _ id: Int,
        _ tag: PreparationTag,
        _ content: String
    ) -> TimelineDiscovery {
        TimelineDiscovery(id: id, tag: tag, content: content)
    }

    private func item(
        _ id: Int,
        _ tag: PreparationTag,
        _ title: String,
        _ isChecked: Bool,
        actionTitle: String? = nil,
        actionURL: String? = nil
    ) -> TimelineChecklistItem {
        TimelineChecklistItem(
            id: id,
            tag: tag,
            title: title,
            isChecked: isChecked,
            actionTitle: actionTitle,
            actionURL: actionURL.flatMap(URL.init(string:))
        )
    }
}
