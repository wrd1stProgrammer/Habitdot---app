import Foundation

enum GridDisplayMode: String, CaseIterable, Identifiable {
    case dots
    case calendar

    var id: String { rawValue }
}
