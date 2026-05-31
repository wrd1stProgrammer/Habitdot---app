import SwiftUI

struct HabitDotMatrixView: View {
    @Environment(HabitStore.self) private var store
    let dates: [Date]
    let color: Color
    let isComplete: (Date) -> Bool
    let period: HabitGridPeriod

    var body: some View {
        if period == .quarterly {
            quarterlyView
        } else {
            LazyVGrid(columns: columns, alignment: .leading, spacing: dotSpacing) {
                ForEach(dates, id: \.self) { date in
                    dot(for: date)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(summary)
        }
    }

    private var quarterlyView: some View {
        HStack(alignment: .top, spacing: 18) {
            ForEach(monthsInQuarter, id: \.self) { monthDate in
                QuarterDotMonthView(
                    monthDate: monthDate,
                    color: color,
                    isComplete: isComplete,
                    calendar: calendar
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    @ViewBuilder
    private func dot(for date: Date) -> some View {
        Circle()
            .fill(isComplete(date) ? color : Color(.systemGray5))
            .frame(width: dotSize, height: dotSize)
            .overlay {
                if calendar.isDateInToday(date) {
                    Circle()
                        .stroke(color, lineWidth: 1.5)
                        .frame(width: dotSize + 5, height: dotSize + 5)
                }
            }
    }

    private var columns: [GridItem] {
        let count = switch period {
        case .weekly: 7
        case .monthly: 7
        case .quarterly: 5
        }
        return Array(repeating: GridItem(.fixed(dotSize), spacing: dotSpacing), count: count)
    }

    private var dotSize: CGFloat {
        switch period {
        case .weekly: 16
        case .monthly: 14
        case .quarterly: 15
        }
    }

    private var dotSpacing: CGFloat {
        switch period {
        case .weekly: 11
        case .monthly: 8
        case .quarterly: 4
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppLocalization.selectedLocale
        calendar.firstWeekday = store.snapshot.settings.firstWeekday
        return calendar
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
}

private struct QuarterDotMonthView: View {
    let monthDate: Date
    let color: Color
    let isComplete: (Date) -> Bool
    let calendar: Calendar

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<7, id: \.self) { weekdayIndex in
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { column in
                        if let date = dateForWeekday(weekdayIndex, at: column) {
                            Circle()
                                .fill(isComplete(date) ? color : Color(.systemGray5))
                                .frame(width: 15, height: 15)
                                .overlay {
                                    if calendar.isDateInToday(date) {
                                        Circle()
                                            .stroke(color, lineWidth: 1.4)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                        } else {
                            Color.clear
                                .frame(width: 15, height: 15)
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

    private func dateForWeekday(_ weekdayIndex: Int, at index: Int) -> Date? {
        let dates = datesForWeekday(weekdayIndex)
        return dates.indices.contains(index) ? dates[index] : nil
    }
}
