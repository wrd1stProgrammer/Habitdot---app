import Foundation

enum OnboardingPage: Int, CaseIterable, Identifiable {
    case intro
    case blockers
    case startStyle
    case reason
    case motivation
    case source
    case proof
    case firstHabit
    case reminder
    case theme

    var id: Int { rawValue }

    var titleKey: String {
        switch self {
        case .intro: "onboarding.intro.title"
        case .blockers: "onboarding.blockers.title"
        case .startStyle: "onboarding.start.title"
        case .reason: "onboarding.reason.title"
        case .motivation: "onboarding.motivation.title"
        case .source: "onboarding.source.title"
        case .proof: "onboarding.proof.title"
        case .firstHabit: "onboarding.habit.title"
        case .reminder: "onboarding.reminder.title"
        case .theme: "onboarding.theme.title"
        }
    }

    var requiresSelection: Bool {
        switch self {
        case .intro, .proof, .reminder:
            false
        default:
            true
        }
    }

    var options: [OnboardingOption] {
        switch self {
        case .intro:
            []
        case .blockers:
            [
                OnboardingOption(id: "unclear", symbolName: "questionmark.circle", titleKey: "onboarding.blockers.unclear"),
                OnboardingOption(id: "delay", symbolName: "hourglass", titleKey: "onboarding.blockers.delay"),
                OnboardingOption(id: "fade", symbolName: "chart.line.downtrend.xyaxis", titleKey: "onboarding.blockers.fade"),
                OnboardingOption(id: "forget", symbolName: "bell", titleKey: "onboarding.blockers.forget")
            ]
        case .startStyle:
            [
                OnboardingOption(id: "today", symbolName: "checkmark.circle", titleKey: "onboarding.start.today"),
                OnboardingOption(id: "fewDays", symbolName: "calendar", titleKey: "onboarding.start.fewDays"),
                OnboardingOption(id: "prepare", symbolName: "map", titleKey: "onboarding.start.prepare"),
                OnboardingOption(id: "reminder", symbolName: "bell.badge", titleKey: "onboarding.start.reminder")
            ]
        case .reason:
            [
                OnboardingOption(id: "firstStep", symbolName: "flag", titleKey: "onboarding.reason.firstStep"),
                OnboardingOption(id: "time", symbolName: "clock", titleKey: "onboarding.reason.time"),
                OnboardingOption(id: "energy", symbolName: "battery.25", titleKey: "onboarding.reason.energy"),
                OnboardingOption(id: "priority", symbolName: "arrow.up.arrow.down", titleKey: "onboarding.reason.priority")
            ]
        case .motivation:
            [
                OnboardingOption(id: "health", symbolName: "heart", titleKey: "onboarding.motivation.health"),
                OnboardingOption(id: "calm", symbolName: "leaf", titleKey: "onboarding.motivation.calm"),
                OnboardingOption(id: "routine", symbolName: "repeat", titleKey: "onboarding.motivation.routine"),
                OnboardingOption(id: "goals", symbolName: "target", titleKey: "onboarding.motivation.goals")
            ]
        case .source:
            [
                OnboardingOption(id: "app-store", symbolName: "bag", titleKey: "onboarding.source.appstore"),
                OnboardingOption(id: "tiktok", symbolName: "music.note", titleKey: "onboarding.source.tiktok"),
                OnboardingOption(id: "instagram", symbolName: "camera", titleKey: "onboarding.source.instagram"),
                OnboardingOption(id: "google", symbolName: "magnifyingglass", titleKey: "onboarding.source.google"),
                OnboardingOption(id: "x", symbolName: "xmark", titleKey: "onboarding.source.x"),
                OnboardingOption(id: "friend", symbolName: "person.2", titleKey: "onboarding.source.friend"),
                OnboardingOption(id: "youtube", symbolName: "play.rectangle", titleKey: "onboarding.source.youtube"),
                OnboardingOption(id: "other", symbolName: "ellipsis", titleKey: "onboarding.source.other")
            ]
        case .proof, .reminder:
            []
        case .firstHabit:
            [
                OnboardingOption(id: "onboarding.habit.walk", symbolName: "figure.walk", titleKey: "onboarding.habit.walk"),
                OnboardingOption(id: "onboarding.habit.water", symbolName: "drop", titleKey: "onboarding.habit.water"),
                OnboardingOption(id: "onboarding.habit.read", symbolName: "book", titleKey: "onboarding.habit.read"),
                OnboardingOption(id: "onboarding.habit.exercise", symbolName: "dumbbell", titleKey: "onboarding.habit.exercise"),
                OnboardingOption(id: "onboarding.habit.sleep", symbolName: "moon", titleKey: "onboarding.habit.sleep")
            ]
        case .theme:
            [
                OnboardingOption(id: "system", symbolName: "circle.lefthalf.filled", titleKey: "onboarding.theme.system"),
                OnboardingOption(id: "light", symbolName: "sun.max", titleKey: "onboarding.theme.light"),
                OnboardingOption(id: "dark", symbolName: "moon.stars", titleKey: "onboarding.theme.dark")
            ]
        }
    }
}
