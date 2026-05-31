import Foundation

struct HabitSuggestion: Identifiable {
    let id = UUID()
    let titleKey: String
    let symbolName: String
    let colorToken: HabitColorToken
}
