import Foundation

enum WidgetSampleData {
    static var snapshot: HabitSnapshot {
        let read = Habit(title: String(localized: "widget.sample.read"), symbolName: "book", colorToken: .amber, frequency: .everyday, displayOrder: 0)
        let exercise = Habit(title: String(localized: "widget.sample.exercise"), symbolName: "dumbbell", colorToken: .indigo, frequency: .everyday, displayOrder: 1)
        let hydrate = Habit(title: String(localized: "widget.sample.hydrate"), symbolName: "drop", colorToken: .rose, frequency: .everyday, targetCount: 2, displayOrder: 2)
        var snapshot = HabitSnapshot(habits: [read, exercise, hydrate], completions: [], settings: .default, updatedAt: Date())
        let days = HabitDate.daysEndingToday(Date(), count: 28)
        for (index, day) in days.enumerated() {
            let key = HabitDate.dayKey(day)
            if index % 4 != 0 {
                snapshot.setCount(1, for: read.id, dayKey: key)
            }
            if index % 3 != 0 {
                snapshot.setCount(1, for: exercise.id, dayKey: key)
            }
            if index % 2 == 0 {
                snapshot.setCount(2, for: hydrate.id, dayKey: key)
            }
        }
        return snapshot
    }
}
