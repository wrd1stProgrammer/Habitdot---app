import SwiftUI

struct ReminderToggleRowView: View {
    @Binding var isOn: Bool
    @Binding var time: Date

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $isOn.animation(.spring(response: 0.34, dampingFraction: 0.86))) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("add.reminder")
                        .font(.subheadline.weight(.semibold))
                    Text("add.reminder.subtitle")
                        .font(.footnote)
                        .foregroundStyle(Color.habitdotSecondaryText)
                }
            }
            .tint(Color.habitdotAccent)

            if isOn {
                Divider()
                    .opacity(0.55)

                DatePicker("add.reminder.time", selection: $time, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.semibold))
                    .datePickerStyle(.compact)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(14)
        .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: isOn)
    }
}
