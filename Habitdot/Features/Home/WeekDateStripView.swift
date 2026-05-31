import SwiftUI

struct WeekDateStripView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                WeekDateCellView(date: date, isSelected: calendar.isDate(date, inSameDayAs: store.selectedDate))
                .frame(maxWidth: .infinity)
            }
        }
        .allowsHitTesting(false)
    }

    private var dates: [Date] {
        HabitDate.daysInWeek(containing: store.selectedDate, calendar: calendar)
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = store.snapshot.settings.firstWeekday
        return calendar
    }
}
