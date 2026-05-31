import Foundation

enum HabitFrequency: Codable, Hashable, Sendable {
    case everyday
    case timesPerWeek(Int)

    private enum CodingKeys: String, CodingKey {
        case kind
        case count
    }

    private enum Kind: String, Codable {
        case everyday
        case timesPerWeek
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .everyday:
            self = .everyday
        case .timesPerWeek:
            let count = try container.decode(Int.self, forKey: .count)
            self = .timesPerWeek(count)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .everyday:
            try container.encode(Kind.everyday, forKey: .kind)
        case .timesPerWeek(let count):
            try container.encode(Kind.timesPerWeek, forKey: .kind)
            try container.encode(count, forKey: .count)
        }
    }
}
