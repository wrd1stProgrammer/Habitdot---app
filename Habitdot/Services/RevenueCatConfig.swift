import Foundation

enum RevenueCatConfig {
    // RevenueCat public iOS SDK key. Replace this with the key from RevenueCat Project Settings > API keys.
    static let publicAPIKey = "appl_KlazeDKmxaXZnllEqatqKXvBwfM"
    static let proEntitlementID = "pro"

    static var hasValidPublicAPIKey: Bool {
        publicAPIKey.hasPrefix("appl_")
    }
}

enum HabitdotProPlan: String, CaseIterable, Identifiable, Sendable {
    case annual
    case monthly
    case lifetime

    var id: String { rawValue }

    var productIdentifier: String {
        switch self {
        case .annual:
            "habitdot1year"
        case .monthly:
            "habitdot1month"
        case .lifetime:
            "habitdotlifetime"
        }
    }

    var titleKey: String {
        switch self {
        case .annual:
            "paywall.plan.annual.title"
        case .monthly:
            "paywall.plan.monthly.title"
        case .lifetime:
            "paywall.plan.lifetime.title"
        }
    }

    var subtitleKey: String {
        switch self {
        case .annual:
            "paywall.plan.annual.subtitle"
        case .monthly:
            "paywall.plan.monthly.subtitle"
        case .lifetime:
            "paywall.plan.lifetime.subtitle"
        }
    }

    var fallbackPriceKey: String {
        switch self {
        case .annual:
            "paywall.plan.annual.price"
        case .monthly:
            "paywall.plan.monthly.price"
        case .lifetime:
            "paywall.plan.lifetime.price"
        }
    }

    var fallbackWeeklyPriceKey: String? {
        switch self {
        case .annual:
            "paywall.plan.annual.weeklyPrice"
        case .monthly:
            "paywall.plan.monthly.weeklyPrice"
        case .lifetime:
            nil
        }
    }

    var badgeKey: String? {
        switch self {
        case .annual:
            "paywall.plan.annual.badge"
        case .monthly:
            nil
        case .lifetime:
            "paywall.plan.lifetime.badge"
        }
    }

    static let defaultPlan: HabitdotProPlan = .annual
}
