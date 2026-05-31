import SwiftUI

enum HabitColorToken: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case amber
    case orange
    case peach
    case coral
    case rose
    case pink
    case magenta
    case indigo
    case purple
    case lavender
    case violet
    case blue
    case sky
    case cyan
    case teal
    case mint
    case green
    case lime
    case yellow
    case sand
    case brown
    case red
    case graphite
    case slate

    var id: String { rawValue }

    static let freeCases: [HabitColorToken] = [.amber, .rose, .indigo, .mint, .blue, .violet]

    var isFreeIncluded: Bool {
        Self.freeCases.contains(self)
    }

    var color: Color {
        Color(hex: hex)
    }

    var hex: UInt32 {
        switch self {
        case .amber: 0xF8B333
        case .orange: 0xF58220
        case .peach: 0xFF9F7A
        case .coral: 0xFF6B5E
        case .rose: 0xF24868
        case .pink: 0xFF5DA2
        case .magenta: 0xD946EF
        case .indigo: 0x6257D8
        case .purple: 0x7C3AED
        case .lavender: 0xA78BFA
        case .violet: 0x9B5DE5
        case .blue: 0x3D8BFF
        case .sky: 0x38BDF8
        case .cyan: 0x22D3EE
        case .teal: 0x14B8A6
        case .mint: 0x2FC79A
        case .green: 0x22C55E
        case .lime: 0x84CC16
        case .yellow: 0xFACC15
        case .sand: 0xD8B26E
        case .brown: 0xA06A4B
        case .red: 0xEF4444
        case .graphite: 0x52525B
        case .slate: 0x64748B
        }
    }
}
