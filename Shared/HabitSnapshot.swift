import Foundation

struct HabitSnapshot: Codable, Hashable, Sendable {
    var habits: [Habit]
    var completions: [HabitCompletion]
    var settings: HabitSettings
    var updatedAt: Date

    static let empty = HabitSnapshot(
        habits: [],
        completions: [],
        settings: .default,
        updatedAt: Date()
    )

    var activeHabits: [Habit] {
        habits
            .filter { !$0.isArchived }
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    var accessibleActiveHabits: [Habit] {
        settings.isProUnlocked ? activeHabits : Array(activeHabits.prefix(3))
    }

    var archivedHabits: [Habit] {
        habits
            .filter(\.isArchived)
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    func completion(for habitID: String, dayKey: String) -> HabitCompletion? {
        completions.first { $0.habitID == habitID && $0.dayKey == dayKey }
    }

    func count(for habitID: String, dayKey: String) -> Int {
        completion(for: habitID, dayKey: dayKey)?.count ?? 0
    }

    func isComplete(_ habit: Habit, dayKey: String) -> Bool {
        count(for: habit.id, dayKey: dayKey) >= habit.targetCount
    }

    mutating func setCount(_ count: Int, for habitID: String, dayKey: String) {
        let sanitizedCount = max(0, count)
        if let index = completions.firstIndex(where: { $0.habitID == habitID && $0.dayKey == dayKey }) {
            if sanitizedCount == 0 {
                completions.remove(at: index)
            } else {
                completions[index].count = sanitizedCount
                completions[index].updatedAt = Date()
            }
        } else if sanitizedCount > 0 {
            completions.append(HabitCompletion(habitID: habitID, dayKey: dayKey, count: sanitizedCount))
        }
        updatedAt = Date()
    }

    mutating func toggleCompletion(for habitID: String, dayKey: String) {
        guard let habit = habits.first(where: { $0.id == habitID }) else { return }
        let currentCount = count(for: habitID, dayKey: dayKey)
        let nextCount = currentCount >= habit.targetCount ? 0 : min(habit.targetCount, currentCount + 1)
        setCount(nextCount, for: habitID, dayKey: dayKey)
    }
}
