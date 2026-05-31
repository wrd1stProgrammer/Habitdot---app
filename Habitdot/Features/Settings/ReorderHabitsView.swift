import SwiftUI

struct ReorderHabitsView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        List {
            ForEach(store.activeHabits) { habit in
                HStack(spacing: 14) {
                    Circle()
                        .fill(habit.colorToken.color)
                        .frame(width: 14, height: 14)
                    Text(habit.title)
                        .font(.headline)
                }
                .padding(.vertical, 6)
            }
            .onMove(perform: store.moveHabit)
        }
        .toolbar {
            EditButton()
        }
    }
}
