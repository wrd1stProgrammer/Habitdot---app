import SwiftUI

struct UpcomingRemindersView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CommonReminderRowView()

                ForEach(store.activeHabits) { habit in
                    ReminderHabitRowView(habit: habit)
                }
            }
            .padding(16)
        }
    }
}
