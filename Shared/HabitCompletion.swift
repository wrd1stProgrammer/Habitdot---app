import Foundation

struct HabitCompletion: Identifiable, Codable, Hashable, Sendable {
    var habitID: String
    var dayKey: String
    var count: Int
    var updatedAt: Date

    var id: String { "\(habitID)-\(dayKey)" }

    init(habitID: String, dayKey: String, count: Int, updatedAt: Date = Date()) {
        self.habitID = habitID
        self.dayKey = dayKey
        self.count = max(0, count)
        self.updatedAt = updatedAt
    }
}
