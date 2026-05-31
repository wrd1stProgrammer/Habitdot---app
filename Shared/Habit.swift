import Foundation

struct Habit: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var title: String
    var purpose: String?
    var symbolName: String
    var colorToken: HabitColorToken
    var frequency: HabitFrequency
    var targetCount: Int
    var reminderHour: Int?
    var reminderMinute: Int?
    var displayOrder: Int
    var isArchived: Bool
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        purpose: String? = nil,
        symbolName: String,
        colorToken: HabitColorToken,
        frequency: HabitFrequency,
        targetCount: Int = 1,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil,
        displayOrder: Int,
        isArchived: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.purpose = purpose
        self.symbolName = symbolName
        self.colorToken = colorToken
        self.frequency = frequency
        self.targetCount = max(1, targetCount)
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.displayOrder = displayOrder
        self.isArchived = isArchived
        self.createdAt = createdAt
    }
}
