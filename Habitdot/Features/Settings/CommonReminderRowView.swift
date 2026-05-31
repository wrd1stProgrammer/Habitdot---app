import SwiftUI

struct CommonReminderRowView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: enabledBinding.animation(.spring(response: 0.34, dampingFraction: 0.86))) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.reminders.common")
                        .font(.headline)
                        .foregroundStyle(Color.habitdotInk)

                    Text(reminderText)
                        .font(.subheadline)
                        .foregroundStyle(Color.habitdotSecondaryText)
                }
            }
            .tint(Color.habitdotAccent)

            if store.snapshot.settings.commonReminderHour != nil {
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
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: store.snapshot.settings.commonReminderHour != nil)
    }

    private var reminderText: String {
        guard let hour = store.snapshot.settings.commonReminderHour else {
            return AppLocalization.localizedString("settings.reminders.off")
        }
        let minute = store.snapshot.settings.commonReminderMinute ?? 0
        return String(format: AppLocalization.localizedString("settings.reminders.time"), hour, minute)
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { store.snapshot.settings.commonReminderHour != nil },
            set: { enabled in
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                store.setCommonReminder(
                    enabled: enabled,
                    hour: components.hour ?? 21,
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
                store.setCommonReminder(
                    enabled: true,
                    hour: components.hour ?? 21,
                    minute: components.minute ?? 0
                )
            }
        )
    }

    private var reminderDate: Date {
        reminderDate(
            hour: store.snapshot.settings.commonReminderHour ?? 21,
            minute: store.snapshot.settings.commonReminderMinute ?? 0
        )
    }

    private func reminderDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
