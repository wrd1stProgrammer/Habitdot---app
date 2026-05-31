import Foundation

enum HabitGridPeriod: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case weekly
    case monthly
    case quarterly

    var id: String { rawValue }
}
