import SwiftUI

struct WidgetDotGridView: View {
    let dates: [Date]
    let habit: Habit
    let snapshot: HabitSnapshot
    let columns: Int
    let dotSize: CGFloat
    let spacing: CGFloat
    let firstWeekday: Int
    let isCalendarAligned: Bool

    init(
        dates: [Date],
        habit: Habit,
        snapshot: HabitSnapshot,
        columns: Int,
        dotSize: CGFloat,
        spacing: CGFloat,
        firstWeekday: Int = Calendar.current.firstWeekday,
        isCalendarAligned: Bool = false
    ) {
        self.dates = dates
        self.habit = habit
        self.snapshot = snapshot
        self.columns = columns
        self.dotSize = dotSize
        self.spacing = spacing
        self.firstWeekday = firstWeekday
        self.isCalendarAligned = isCalendarAligned
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, date in
                        if let date {
                            Circle()
                                .fill(dotColor(for: date))
                                .overlay {
                                    if calendar.isDateInToday(date) {
                                        Circle()
                                            .stroke(Color.white.opacity(0.42), lineWidth: 1.2)
                                    }
                                }
                                .frame(width: dotSize, height: dotSize)
                        } else {
                            Color.clear
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    private var rows: [[Date?]] {
        stride(from: 0, to: cells.count, by: columns).map { start in
            Array(cells[start..<min(start + columns, cells.count)])
        }
    }

    private var cells: [Date?] {
        guard isCalendarAligned else { return dates.map(Optional.some) }
        return Array(repeating: nil, count: leadingBlankCount) + dates.map(Optional.some)
    }

    private var leadingBlankCount: Int {
        guard let firstDate = dates.first else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDate)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func dotColor(for date: Date) -> Color {
        snapshot.isComplete(habit, dayKey: HabitDate.dayKey(date)) ? habit.colorToken.color : Color.habitdotWidgetMutedDot
    }

    private var summary: Text {
        let count = dates.filter { snapshot.isComplete(habit, dayKey: HabitDate.dayKey($0)) }.count
        return Text(String(format: String(localized: "widget.completedSummary"), count))
    }
}
