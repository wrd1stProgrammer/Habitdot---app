import SwiftUI

struct GridHabitCardView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(habit.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.habitdotInk)
                Spacer()
                Text(HabitdotDisplayText.frequency(habit.frequency))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.habitdotSecondaryText)
            }

            Group {
                if store.gridDisplayMode == .calendar {
                    HabitCalendarMatrixView(
                        dates: store.progressDates(for: store.gridPeriod, around: store.gridReferenceDate),
                        color: habit.colorToken.color,
                        isComplete: { store.isComplete(habit, on: $0) },
                        period: store.gridPeriod
                    )
                } else {
                    HabitDotMatrixView(
                        dates: store.progressDates(for: store.gridPeriod, around: store.gridReferenceDate),
                        color: habit.colorToken.color,
                        isComplete: { store.isComplete(habit, on: $0) },
                        period: store.gridPeriod
                    )
                }
            }
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .habitdotCard()
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: store.gridPeriod)
    }
}
