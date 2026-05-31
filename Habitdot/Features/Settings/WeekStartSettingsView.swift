import SwiftUI

struct WeekStartSettingsView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("settings.weekStart.section")
                .font(.headline)
                .foregroundStyle(Color.habitdotSecondaryText)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                SettingsSelectableRowView(title: "settings.weekStart.row", isSelected: false, action: {})
                Divider().padding(.leading, 20)
                ForEach(1...7, id: \.self) { weekday in
                    SettingsSelectableRowView(
                        title: weekdayTitle(weekday),
                        isSelected: store.snapshot.settings.firstWeekday == weekday,
                        action: { store.setFirstWeekday(weekday) }
                    )
                    if weekday != 7 {
                        Divider().padding(.leading, 20)
                    }
                }
            }
            .habitdotCard()
            Spacer()
        }
        .padding(16)
    }

    private func weekdayTitle(_ weekday: Int) -> String {
        switch weekday {
        case 1: "settings.weekday.sunday"
        case 2: "settings.weekday.monday"
        case 3: "settings.weekday.tuesday"
        case 4: "settings.weekday.wednesday"
        case 5: "settings.weekday.thursday"
        case 6: "settings.weekday.friday"
        default: "settings.weekday.saturday"
        }
    }
}
