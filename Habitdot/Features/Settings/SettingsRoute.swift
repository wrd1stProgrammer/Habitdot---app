import Foundation

enum SettingsRoute: String, CaseIterable, Hashable, Identifiable {
    case appearance
    case language
    case weekStart
    case reminders
    case reorder
    case archived
    case importExport
    case widgetGuide
    case discord
    case instagram
    case feedback
    case contact
    case bug
    case review
    case privacy
    case terms

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .appearance: "settings.appearance"
        case .language: "settings.language"
        case .weekStart: "settings.weekStart"
        case .reminders: "settings.reminders"
        case .reorder: "settings.reorder"
        case .archived: "settings.archived"
        case .importExport: "settings.importExport"
        case .widgetGuide: "settings.widgetGuide"
        case .discord: "settings.discord"
        case .instagram: "settings.instagram"
        case .feedback: "settings.feedback"
        case .contact: "settings.contact"
        case .bug: "settings.bug"
        case .review: "settings.review"
        case .privacy: "settings.privacy"
        case .terms: "settings.terms"
        }
    }
}
