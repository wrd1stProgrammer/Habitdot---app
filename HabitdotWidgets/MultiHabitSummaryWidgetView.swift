import SwiftUI
import WidgetKit

struct MultiHabitSummaryWidgetView: View {
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
                    titleKey: "widget.pro.summary.title",
                    bodyKey: "widget.pro.body"
                )
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray)
                    .frame(width: labelColumnWidth, alignment: .leading)

                if !habits.isEmpty {
                    HStack(spacing: dotSpacing) {
                        ForEach(weekSymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.gray)
                                .frame(width: dotSize)
                        }
                    }
                }
            }

            if habits.isEmpty {
                Text("widget.empty")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(habits) { habit in
                    HStack(alignment: .center, spacing: columnGap) {
                        HStack(spacing: 9) {
                            WidgetCheckButtonView(habit: habit, snapshot: entry.snapshot, size: 25)
                            Text(habit.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.86))
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                        .frame(width: labelColumnWidth, alignment: .leading)

                        HStack(spacing: dotSpacing) {
                            ForEach(HabitDate.daysEndingToday(entry.date, count: 7), id: \.self) { date in
                                Circle()
                                    .fill(entry.snapshot.isComplete(habit, dayKey: HabitDate.dayKey(date)) ? habit.colorToken.color : Color.habitdotWidgetMutedDot)
                                    .frame(width: dotSize, height: dotSize)
                            }
                        }
                    }
                    .frame(height: 27)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .containerBackground(Color.habitdotWidgetBackground, for: .widget)
    }

    private var habits: [Habit] {
        Array(entry.snapshot.accessibleActiveHabits.prefix(3))
    }

    private let labelColumnWidth: CGFloat = 156
    private let columnGap: CGFloat = 13
    private let dotSize: CGFloat = 12
    private let dotSpacing: CGFloat = 9

    private var weekSymbols: [String] {
        var calendar = Calendar.current
        calendar.firstWeekday = entry.snapshot.settings.firstWeekday
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        return (0..<7).map { index in
            symbols[(calendar.firstWeekday - 1 + index) % 7]
        }
    }
}
