import SwiftUI
import WidgetKit

struct ThreeMonthWidgetView: View {
    let entry: HabitdotWidgetEntry

    var body: some View {
        if !entry.snapshot.settings.isProUnlocked {
            ZStack {
                content
                    .blur(radius: 7)
                    .saturation(0.9)
                    .brightness(-0.05)
                    .overlay(Color.black.opacity(0.28))
                    .allowsHitTesting(false)

                ProWidgetLockView(
                    titleKey: "widget.pro.threeMonth.title",
                    bodyKey: "widget.pro.body"
                )
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let habit = entry.snapshot.accessibleActiveHabits.first {
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray)

                HStack(spacing: 9) {
                    WidgetCheckButtonView(habit: habit, snapshot: entry.snapshot, size: 24)
                    Text(habit.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }

                HStack(alignment: .top, spacing: 12) {
                    ForEach(monthBlocks, id: \.id) { block in
                        WidgetDotGridView(
                            dates: block.dates,
                            habit: habit,
                            snapshot: entry.snapshot,
                            columns: 7,
                            dotSize: 9.4,
                            spacing: 3.7,
                            firstWeekday: entry.snapshot.settings.firstWeekday,
                            isCalendarAligned: true
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 3)
            } else {
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray)
                Text("widget.empty")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .containerBackground(Color.habitdotWidgetBackground, for: .widget)
    }

    private var monthBlocks: [MonthBlock] {
        (-2...0).compactMap { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: entry.date) else {
                return nil
            }
            return MonthBlock(
                id: HabitDate.dayKey(monthDate, calendar: calendar),
                dates: HabitDate.daysInMonth(containing: monthDate, calendar: calendar)
            )
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = entry.snapshot.settings.firstWeekday
        return calendar
    }
}

private struct MonthBlock: Identifiable {
    let id: String
    let dates: [Date]
}
