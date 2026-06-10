import Foundation

struct OnboardingCompletionPayload: Hashable {
    let preferredHabitKey: String?
    let customHabitTitle: String?
    let preferredAppearanceID: String?
    let commonReminderTime: DateComponents?
    let selections: [String: String]
    let source: String?
    let localeIdentifier: String
    let countryCode: String?
    let timeZoneIdentifier: String
    let appVersion: String
    let buildNumber: String
    let completedAt: Date

    static func make(
        selectedOptions: [OnboardingPage: String],
        commonReminderTime: DateComponents?,
        customHabitTitle: String? = nil
    ) -> OnboardingCompletionPayload {
        let trimmedCustomHabitTitle = customHabitTitle?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedFirstHabit = selectedOptions[.firstHabit]
        let usableCustomHabitTitle = selectedFirstHabit == OnboardingHabitSelection.customID && trimmedCustomHabitTitle?.isEmpty == false
        ? trimmedCustomHabitTitle
        : nil
        let selections = selectedOptions.reduce(into: [String: String]()) { result, item in
            result[item.key.analyticsKey] = item.value
        }

        return OnboardingCompletionPayload(
            preferredHabitKey: selectedFirstHabit,
            customHabitTitle: usableCustomHabitTitle,
            preferredAppearanceID: selectedOptions[.theme],
            commonReminderTime: commonReminderTime,
            selections: selections,
            source: selectedOptions[.source],
            localeIdentifier: Locale.autoupdatingCurrent.identifier,
            countryCode: Locale.autoupdatingCurrent.habitdotCountryCode,
            timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-",
            completedAt: Date()
        )
    }
}

extension OnboardingPage {
    var analyticsKey: String {
        switch self {
        case .intro:
            "intro"
        case .blockers:
            "blocker"
        case .startStyle:
            "start_style"
        case .reason:
            "break_reason"
        case .motivation:
            "motivation"
        case .source:
            "source"
        case .proof:
            "proof"
        case .firstHabit:
            "first_habit"
        case .reminder:
            "reminder"
        case .theme:
            "theme"
        }
    }
}

extension Locale {
    var habitdotCountryCode: String? {
        region?.identifier.uppercased()
    }
}
