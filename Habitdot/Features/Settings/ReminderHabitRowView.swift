import SwiftUI

struct ReminderHabitRowView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                Circle()
                    .fill(habit.colorToken.color)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundStyle(Color.habitdotInk)
                    Text(reminderText)
                        .font(.subheadline)
                        .foregroundStyle(Color.habitdotSecondaryText)
                }

                Spacer()

                Toggle("settings.reminders.toggle", isOn: reminderBinding.animation(.spring(response: 0.34, dampingFraction: 0.86)))
                    .labelsHidden()
                    .tint(Color.habitdotAccent)
            }

            if habit.reminderHour != nil {
                Divider()
                    .opacity(0.55)

                DatePicker("settings.reminders.timePicker", selection: timeBinding, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.semibold))
                    .datePickerStyle(.compact)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(18)
        .habitdotCard()
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: habit.reminderHour != nil)
    }

    private var reminderText: String {
        guard let hour = habit.reminderHour else {
            return AppLocalization.localizedString("settings.reminders.off")
        }
        let minute = habit.reminderMinute ?? 0
        return String(format: AppLocalization.localizedString("settings.reminders.time"), hour, minute)
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { habit.reminderHour != nil },
            set: { enabled in
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                store.setReminder(
                    for: habit,
                    enabled: enabled,
                    hour: components.hour ?? 9,
                    minute: components.minute ?? 0
                )
            }
        )
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: { reminderDate },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                store.setReminder(
                    for: habit,
                    enabled: true,
                    hour: components.hour ?? 9,
                    minute: components.minute ?? 0
                )
            }
        )
    }

    private var reminderDate: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = habit.reminderHour ?? 9
        components.minute = habit.reminderMinute ?? 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
