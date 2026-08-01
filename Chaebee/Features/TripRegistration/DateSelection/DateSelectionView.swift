import SwiftUI

struct DateSelectionView: View {
    @ObservedObject private var registration: TripRegistrationViewModel

    @State private var selectionPhase = TripDateSelectionPhase.departure
    @State private var departureDate: Date?
    @State private var returnDate: Date?
    @State private var showsESIMPlanSelection = false

    init(registration: TripRegistrationViewModel) {
        self.registration = registration
    }

    private var step: LocalizedStringResource {
        switch selectionPhase {
        case .departure:
            "tripRegistration.step.twoOfFive"
        case .returnDate:
            "tripRegistration.step.threeOfFive"
        }
    }

    private var title: LocalizedStringResource {
        switch selectionPhase {
        case .departure:
            "tripRegistration.dateSelection.departure.title"
        case .returnDate:
            "tripRegistration.dateSelection.return.title"
        }
    }

    var body: some View {
        TripRegistrationStepLayout(
            step: step,
            title: title,
            subtitle: "tripRegistration.dateSelection.subtitle",
            isNextEnabled: departureDate != nil && returnDate != nil,
            onNext: { showsESIMPlanSelection = true }
        ) {
            TripDateCalendar(
                selectionPhase: selectionPhase,
                departureDate: departureDate,
                returnDate: returnDate,
                onSelect: select
            )
        }
        .navigationDestination(isPresented: $showsESIMPlanSelection) {
            ESIMPlanSelectionView(registration: registration)
        }
    }

    private func select(_ date: Date) {
        switch selectionPhase {
        case .departure:
            departureDate = date
            returnDate = nil
            registration.selectDepartureDate(date)
            selectionPhase = .returnDate
        case .returnDate:
            guard let departureDate, date >= departureDate else { return }
            returnDate = date
            registration.selectReturnDate(date)
        }
    }
}

private enum TripDateSelectionPhase: Equatable {
    case departure
    case returnDate
}

private struct TripDateCalendar: View {
    @Environment(\.locale) private var locale

    let selectionPhase: TripDateSelectionPhase
    let departureDate: Date?
    let returnDate: Date?
    let onSelect: (Date) -> Void

    @State private var displayedMonth: Date

    private static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }()

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    init(
        selectionPhase: TripDateSelectionPhase,
        departureDate: Date?,
        returnDate: Date?,
        onSelect: @escaping (Date) -> Void
    ) {
        self.selectionPhase = selectionPhase
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.onSelect = onSelect
        _displayedMonth = State(initialValue: Self.startOfMonth(containing: departureDate ?? Date()))
    }

    var body: some View {
        VStack(spacing: CBSpacing.medium) {
            monthHeader

            LazyVGrid(columns: columns, spacing: CBSpacing.small) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(verbatim: symbol.uppercased())
                        .cbTypography(.subhead3)
                        .foregroundStyle(CBColor.gray4)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(monthDates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(CBSpacing.medium)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }

    private var monthHeader: some View {
        HStack(spacing: CBSpacing.small) {
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray9)

            Spacer()

            monthButton(
                systemName: "chevron.left",
                accessibilityLabel: "calendar.previousMonth",
                offset: -1
            )

            monthButton(
                systemName: "chevron.right",
                accessibilityLabel: "calendar.nextMonth",
                offset: 1
            )
        }
    }

    private func monthButton(
        systemName: String,
        accessibilityLabel: LocalizedStringResource,
        offset: Int
    ) -> some View {
        Button {
            guard let month = Self.calendar.date(
                byAdding: .month,
                value: offset,
                to: displayedMonth
            ) else { return }
            displayedMonth = month
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(CBColor.blue5)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    private func dayCell(for date: Date) -> some View {
        let isEndpoint = isSameDay(date, departureDate) || isSameDay(date, returnDate)
        let isBetween = isDateInSelectedRange(date)
        let isEnabled = isDateSelectable(date)

        return Button {
            onSelect(date)
        } label: {
            ZStack {
                if isBetween {
                    TripDateRangeShape(
                        roundsLeadingEdge: roundsLeadingEdge(for: date),
                        roundsTrailingEdge: roundsTrailingEdge(for: date),
                        startsAtSelection: isSameDay(date, departureDate),
                        endsAtSelection: isSameDay(date, returnDate)
                    )
                        .fill(CBColor.blue1)
                        .frame(height: 36)
                }

                if isEndpoint {
                    Circle()
                        .fill(CBColor.blue5)
                        .frame(width: 36, height: 36)
                }

                Text(verbatim: String(Self.calendar.component(.day, from: date)))
                    .cbTypography(.title3)
                    .foregroundStyle(dayColor(isEndpoint: isEndpoint, isEnabled: isEnabled))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.calendar = Self.calendar
        formatter.locale = locale
        return formatter.shortStandaloneWeekdaySymbols
    }

    private var monthDates: [Date?] {
        guard
            let dayRange = Self.calendar.range(of: .day, in: .month, for: displayedMonth),
            let firstDay = Self.calendar.date(
                from: Self.calendar.dateComponents([.year, .month], from: displayedMonth)
            )
        else { return [] }

        let leadingEmptyCount = Self.calendar.component(.weekday, from: firstDay) - 1
        let leadingDates = Array<Date?>(repeating: nil, count: leadingEmptyCount)
        let dates = dayRange.compactMap { day -> Date? in
            Self.calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
        return leadingDates + dates.map(Optional.some)
    }

    private func isDateSelectable(_ date: Date) -> Bool {
        guard selectionPhase == .returnDate, let departureDate else { return true }
        return Self.calendar.compare(date, to: departureDate, toGranularity: .day) != .orderedAscending
    }

    private func isDateInSelectedRange(_ date: Date) -> Bool {
        guard let departureDate, let returnDate else { return false }
        return date >= departureDate && date <= returnDate
    }

    private func roundsLeadingEdge(for date: Date) -> Bool {
        Self.calendar.component(.weekday, from: date) == 1
    }

    private func roundsTrailingEdge(for date: Date) -> Bool {
        Self.calendar.component(.weekday, from: date) == 7
    }

    private func isSameDay(_ date: Date, _ otherDate: Date?) -> Bool {
        guard let otherDate else { return false }
        return Self.calendar.isDate(date, inSameDayAs: otherDate)
    }

    private func dayColor(isEndpoint: Bool, isEnabled: Bool) -> Color {
        if isEndpoint { return .white }
        return isEnabled ? CBColor.gray9 : CBColor.gray3
    }

    private static func startOfMonth(containing date: Date) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: date)
        ) ?? date
    }
}

private struct TripDateRangeShape: Shape {
    let roundsLeadingEdge: Bool
    let roundsTrailingEdge: Bool
    let startsAtSelection: Bool
    let endsAtSelection: Bool

    func path(in rect: CGRect) -> Path {
        var rangeRect = rect

        if startsAtSelection {
            rangeRect.origin.x = rect.midX
            rangeRect.size.width -= rect.width / 2
        }

        if endsAtSelection {
            rangeRect.size.width = max(0, rect.midX - rangeRect.minX)
        }

        guard rangeRect.width > 0 else { return Path() }

        let radius = min(rangeRect.height / 2, rangeRect.width / 2)
        var path = Path()

        path.move(
            to: CGPoint(
                x: roundsLeadingEdge ? rangeRect.minX + radius : rangeRect.minX,
                y: rangeRect.minY
            )
        )
        path.addLine(
            to: CGPoint(
                x: roundsTrailingEdge ? rangeRect.maxX - radius : rangeRect.maxX,
                y: rangeRect.minY
            )
        )

        if roundsTrailingEdge {
            path.addArc(
                center: CGPoint(x: rangeRect.maxX - radius, y: rangeRect.midY),
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rangeRect.maxX, y: rangeRect.maxY))
        }

        path.addLine(
            to: CGPoint(
                x: roundsLeadingEdge ? rangeRect.minX + radius : rangeRect.minX,
                y: rangeRect.maxY
            )
        )

        if roundsLeadingEdge {
            path.addArc(
                center: CGPoint(x: rangeRect.minX + radius, y: rangeRect.midY),
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(270),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: rangeRect.minX, y: rangeRect.minY))
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        DateSelectionView(registration: TripRegistrationViewModel())
    }
    .environment(\.locale, Locale(identifier: "ko"))
}
