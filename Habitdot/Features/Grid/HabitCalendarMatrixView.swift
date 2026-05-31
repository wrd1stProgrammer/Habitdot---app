import SwiftUI

struct HabitCalendarMatrixView: View {
    @Environment(HabitStore.self) private var store
    let dates: [Date]
    let color: Color
    let isComplete: (Date) -> Bool
    let period: HabitGridPeriod

    var body: some View {
        switch period {
        case .weekly:
            weeklyView
        case .monthly:
            monthlyView
        case .quarterly:
            quarterlyView
        }
    }

    private var weeklyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                ForEach(weekSymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.habitdotSecondaryText)
                        .frame(width: 22)
                }
            }

            HStack(spacing: 9) {
                ForEach(dates, id: \.self) { date in
                    CalendarDayBubble(
                        date: date,
                        size: 22,
                        color: color,
                        calendar: calendar,
                        isComplete: isComplete(date)
                    )
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    private var monthlyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(weekSymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.habitdotSecondaryText)
                        .frame(width: 20)
                }
            }

            LazyVGrid(columns: monthColumns, alignment: .leading, spacing: 6) {
                ForEach(Array(monthCells.enumerated()), id: \.offset) { _, date in
                    CalendarDayBubble(
                        date: date,
                        size: 20,
                        color: color,
                        calendar: calendar,
                        isComplete: date.map(isComplete) ?? false
                    )
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    private var quarterlyView: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(monthsInQuarter, id: \.self) { monthDate in
                QuarterMonthGridView(
                    monthDate: monthDate,
                    color: color,
                    isComplete: isComplete,
                    calendar: calendar,
                    weekSymbols: weekSymbols
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppLocalization.selectedLocale
        calendar.firstWeekday = store.snapshot.settings.firstWeekday
        return calendar
    }

    private var weekSymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return (0..<7).map { index in
            symbols[(calendar.firstWeekday - 1 + index) % 7].uppercased()
        }
    }

    private var monthColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(20), spacing: 8), count: 7)
    }

    private var monthCells: [Date?] {
        guard let firstDate = dates.first else { return [] }
        let leading = leadingBlankCount(for: firstDate)
        return Array(repeating: nil, count: leading) + dates.map(Optional.some)
    }

    private var monthsInQuarter: [Date] {
        guard let first = dates.first else { return [] }
        let month = calendar.component(.month, from: first)
        let quarterStartMonth = ((month - 1) / 3) * 3 + 1
        var components = calendar.dateComponents([.year], from: first)
        components.month = quarterStartMonth
        components.day = 1
        guard let start = calendar.date(from: components) else { return [] }
        return (0..<3).compactMap { calendar.date(byAdding: .month, value: $0, to: start) }
    }

    private var summary: Text {
        let count = dates.filter(isComplete).count
        return Text(String(format: AppLocalization.localizedString("grid.completedSummary"), count))
    }

    private func leadingBlankCount(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}

private struct CalendarDayBubble: View {
    let date: Date?
    let size: CGFloat
    let color: Color
    let calendar: Calendar
    let isComplete: Bool

    var body: some View {
        Group {
            if let date {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: size * 0.48, weight: .medium))
                    .foregroundStyle(isComplete ? .white : Color.habitdotSecondaryText)
                    .frame(width: size, height: size)
                    .background(isComplete ? color : Color(.systemGray6), in: Circle())
                    .overlay {
                        if calendar.isDateInToday(date) {
                            Circle()
                                .stroke(color.opacity(0.95), lineWidth: 1.3)
                                .frame(width: size + 5, height: size + 5)
                        }
                    }
            } else {
                Color.clear
                    .frame(width: size, height: size)
            }
        }
    }
}

private struct QuarterMonthGridView: View {
    let monthDate: Date
    let color: Color
    let isComplete: (Date) -> Bool
    let calendar: Calendar
    let weekSymbols: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(AppLocalization.monthAbbreviation(monthDate))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.habitdotSecondaryText)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<7, id: \.self) { weekdayIndex in
                    HStack(spacing: 3) {
                        Text(weekSymbols[weekdayIndex])
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.habitdotSecondaryText)
                            .frame(width: 9)

                        ForEach(0..<5, id: \.self) { column in
                            let date = datesForWeekday(weekdayIndex)[safe: column]
                            CalendarDayBubble(
                                date: date,
                                size: 14,
                                color: color,
                                calendar: calendar,
                                isComplete: date.map(isComplete) ?? false
                            )
                        }
                    }
                }
            }
        }
    }

    private func datesForWeekday(_ weekdayIndex: Int) -> [Date] {
        let weekday = ((calendar.firstWeekday - 1 + weekdayIndex) % 7) + 1
        return HabitDate.daysInMonth(containing: monthDate, calendar: calendar)
            .filter { calendar.component(.weekday, from: $0) == weekday }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
