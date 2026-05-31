import Foundation

enum HabitDate {
    static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func daysAround(_ date: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let center = calendar.startOfDay(for: date)
        let lowerBound = -(count / 2)
        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: lowerBound + offset, to: center)
        }
    }

    static func daysInWeek(containing date: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return daysAround(date, count: 7, calendar: calendar)
        }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: interval.start)
        }
    }

    static func daysEndingToday(_ date: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let end = calendar.startOfDay(for: date)
        return stride(from: count - 1, through: 0, by: -1).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: end)
        }
    }

    static func daysInMonth(containing date: Date, calendar: Calendar = .current) -> [Date] {
        guard
            let interval = calendar.dateInterval(of: .month, for: date),
            let range = calendar.range(of: .day, in: .month, for: date)
        else { return [] }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: interval.start)
        }
    }

    static func daysInQuarter(containing date: Date, calendar: Calendar = .current) -> [Date] {
        let month = calendar.component(.month, from: date)
        let quarterStartMonth = ((month - 1) / 3) * 3 + 1
        var components = calendar.dateComponents([.year], from: date)
        components.month = quarterStartMonth
        components.day = 1
        guard let start = calendar.date(from: components) else { return [] }
        let end = calendar.date(byAdding: .month, value: 3, to: start) ?? start
        var result: [Date] = []
        var cursor = start
        while cursor < end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }
}
