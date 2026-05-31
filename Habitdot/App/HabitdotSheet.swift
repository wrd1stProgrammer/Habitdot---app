import Foundation

enum HabitdotSheet: Identifiable {
    case addHabit
    case editHabit(String)
    case settings

    var id: String {
        switch self {
        case .addHabit: "addHabit"
        case .editHabit(let habitID): "editHabit-\(habitID)"
        case .settings: "settings"
        }
    }
}
