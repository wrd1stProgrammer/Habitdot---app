import SwiftUI

struct HabitProgressDotRowView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            ForEach(dates, id: \.self) { date in
                HabitProgressDotView(
                    color: habit.colorToken.color,
                    isComplete: store.isComplete(habit, on: date),
                    isFuture: date > Date()
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary)
    }

    private var dates: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = store.snapshot.settings.firstWeekday
        return HabitDate.daysInWeek(containing: store.selectedDate, calendar: calendar)
    }

    private var summary: Text {
        let completeCount = dates.filter { store.isComplete(habit, on: $0) }.count
        return Text(String(format: AppLocalization.localizedString("habit.weekSummary"), completeCount))
    }
}
