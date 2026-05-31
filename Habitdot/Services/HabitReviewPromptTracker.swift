import Foundation

enum HabitReviewPromptTracker {
    private static let firstHabitPromptKey = "habitdot.reviewPrompt.firstHabit"

    static var didPromptAfterFirstHabit: Bool {
        UserDefaults.standard.bool(forKey: firstHabitPromptKey)
    }

    static func markPromptedAfterFirstHabit() {
        UserDefaults.standard.set(true, forKey: firstHabitPromptKey)
    }
}
