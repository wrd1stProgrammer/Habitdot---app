import SwiftUI
import WidgetKit

struct TodayChecklistWidgetView: View {
    let entry: HabitdotWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.gray)

            if entry.snapshot.accessibleActiveHabits.isEmpty {
                Text("widget.empty")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(Array(entry.snapshot.accessibleActiveHabits.prefix(3))) { habit in
                    HStack(spacing: 9) {
                        WidgetCheckButtonView(habit: habit, snapshot: entry.snapshot, size: 24)
                        Text(habit.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.86))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(height: 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .containerBackground(Color.habitdotWidgetBackground, for: .widget)
    }
}
