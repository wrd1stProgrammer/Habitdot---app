import SwiftUI
import WidgetKit

struct WidgetCheckButtonView: View {
    let habit: Habit
    let snapshot: HabitSnapshot
    let size: CGFloat

    var body: some View {
        Button(intent: ToggleHabitIntent(habitID: habit.id)) {
            ZStack {
                Circle()
                    .fill(isComplete ? habit.colorToken.color : .clear)
                    .overlay {
                        Circle()
                            .stroke(habit.colorToken.color.opacity(isComplete ? 0 : 0.95), lineWidth: 1.7)
                    }
                    .frame(width: circleSize, height: circleSize)

                Image(systemName: isComplete ? "checkmark" : "plus")
                    .font(.system(size: size * 0.46, weight: .bold))
                    .foregroundStyle(isComplete ? Color.black : habit.colorToken.color)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(isComplete ? "widget.markIncomplete" : "widget.markComplete"))
    }

    private var isComplete: Bool {
        snapshot.isComplete(habit, dayKey: HabitDate.dayKey(Date()))
    }

    private var circleSize: CGFloat {
        max(12, size - 3)
    }
}
