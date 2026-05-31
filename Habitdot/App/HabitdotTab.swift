import Foundation

enum HabitdotTab: String, CaseIterable, Identifiable {
    case today
    case add
    case grid

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .today: "house.fill"
        case .add: "plus"
        case .grid: "square.grid.3x3.fill"
        }
    }

    var accessibilityKey: String {
        switch self {
        case .today: "tab.today"
        case .add: "tab.add"
        case .grid: "tab.grid"
        }
    }
}
