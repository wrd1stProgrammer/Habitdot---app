import Foundation

struct OnboardingOption: Identifiable, Hashable {
    let id: String
    let symbolName: String
    let titleKey: String
}

enum OnboardingHabitSelection {
    static let customID = "custom"
}
