import SwiftUI
import WidgetKit

struct SingleMonthWidgetView: View {
    let entry: HabitdotWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let habit = entry.snapshot.accessibleActiveHabits.first {
                let dates = HabitDate.daysInMonth(containing: entry.date, calendar: widgetCalendar)
                let metrics = gridMetrics(for: dates)

                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.gray)

                HStack(spacing: 9) {
                    WidgetCheckButtonView(habit: habit, snapshot: entry.snapshot, size: 24)
                    Text(habit.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                WidgetDotGridView(
                    dates: dates,
                    habit: habit,
                    snapshot: entry.snapshot,
                    columns: 7,
                    dotSize: metrics.dotSize,
                    spacing: metrics.spacing,
                    firstWeekday: entry.snapshot.settings.firstWeekday,
                    isCalendarAligned: true
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 1)
            } else {
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.gray)
                Text("widget.empty")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .containerBackground(Color.habitdotWidgetBackground, for: .widget)
    }

    private var widgetCalendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = entry.snapshot.settings.firstWeekday
        return calendar
    }

    private func gridMetrics(for dates: [Date]) -> (dotSize: CGFloat, spacing: CGFloat) {
        gridRowCount(for: dates) > 5 ? (10.6, 4.4) : (12.2, 5.2)
    }

    private func gridRowCount(for dates: [Date]) -> Int {
        guard let firstDate = dates.first else { return 0 }
        let leading = (widgetCalendar.component(.weekday, from: firstDate) - widgetCalendar.firstWeekday + 7) % 7
        return (leading + dates.count + 6) / 7
    }
}
