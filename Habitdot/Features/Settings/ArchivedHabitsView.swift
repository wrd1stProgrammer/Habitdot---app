import SwiftUI

struct ArchivedHabitsView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if store.archivedHabits.isEmpty {
                    ContentUnavailableView(
                        "settings.archived.empty",
                        systemImage: "archivebox",
                        description: Text("settings.archived.emptySubtitle")
                    )
                    .padding(.top, 80)
                } else {
                    ForEach(store.archivedHabits) { habit in
                        HStack {
                            Text(habit.title)
                                .font(.headline)
                            Spacer()
                            Button("settings.archived.restore", action: { store.restore(habit) })
                                .font(.headline)
                                .foregroundStyle(Color.habitdotAccent)
                        }
                        .padding(18)
                        .habitdotCard()
                    }
                }
            }
            .padding(16)
        }
    }
}
