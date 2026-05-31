import Foundation

struct HabitSettings: Codable, Hashable, Sendable {
    var appearance: HabitAppearance
    var firstWeekday: Int
    var isProUnlocked: Bool
    var commonReminderHour: Int?
    var commonReminderMinute: Int?
    var onboardingSource: String?
    var onboardingSurvey: [String: String]
    var onboardingCountryCode: String?
    var onboardingLocaleIdentifier: String?
    var onboardingCompletedAt: Date?

    static let `default` = HabitSettings(
        appearance: .system,
        firstWeekday: 2,
        isProUnlocked: false,
        commonReminderHour: nil,
        commonReminderMinute: nil,
        onboardingSource: nil,
        onboardingSurvey: [:],
        onboardingCountryCode: nil,
        onboardingLocaleIdentifier: nil,
        onboardingCompletedAt: nil
    )

    init(
        appearance: HabitAppearance,
        firstWeekday: Int,
        isProUnlocked: Bool,
        commonReminderHour: Int? = nil,
        commonReminderMinute: Int? = nil,
        onboardingSource: String? = nil,
        onboardingSurvey: [String: String] = [:],
        onboardingCountryCode: String? = nil,
        onboardingLocaleIdentifier: String? = nil,
        onboardingCompletedAt: Date? = nil
    ) {
        self.appearance = appearance
        self.firstWeekday = firstWeekday
        self.isProUnlocked = isProUnlocked
        self.commonReminderHour = commonReminderHour
        self.commonReminderMinute = commonReminderMinute
        self.onboardingSource = onboardingSource
        self.onboardingSurvey = onboardingSurvey
        self.onboardingCountryCode = onboardingCountryCode
        self.onboardingLocaleIdentifier = onboardingLocaleIdentifier
        self.onboardingCompletedAt = onboardingCompletedAt
    }

    enum CodingKeys: String, CodingKey {
        case appearance
        case firstWeekday
        case isProUnlocked
        case commonReminderHour
        case commonReminderMinute
        case onboardingSource
        case onboardingSurvey
        case onboardingCountryCode
        case onboardingLocaleIdentifier
        case onboardingCompletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appearance = try container.decodeIfPresent(HabitAppearance.self, forKey: .appearance) ?? .system
        firstWeekday = try container.decodeIfPresent(Int.self, forKey: .firstWeekday) ?? 2
        isProUnlocked = try container.decodeIfPresent(Bool.self, forKey: .isProUnlocked) ?? false
        commonReminderHour = try container.decodeIfPresent(Int.self, forKey: .commonReminderHour)
        commonReminderMinute = try container.decodeIfPresent(Int.self, forKey: .commonReminderMinute)
        onboardingSource = try container.decodeIfPresent(String.self, forKey: .onboardingSource)
        onboardingSurvey = try container.decodeIfPresent([String: String].self, forKey: .onboardingSurvey) ?? [:]
        onboardingCountryCode = try container.decodeIfPresent(String.self, forKey: .onboardingCountryCode)
        onboardingLocaleIdentifier = try container.decodeIfPresent(String.self, forKey: .onboardingLocaleIdentifier)
        onboardingCompletedAt = try container.decodeIfPresent(Date.self, forKey: .onboardingCompletedAt)
    }
}
