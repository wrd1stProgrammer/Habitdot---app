import Foundation

enum HabitdotDisplayText {
    static func frequency(_ frequency: HabitFrequency) -> String {
        switch frequency {
        case .everyday:
            AppLocalization.localizedString("habit.frequency.everyday")
        case .timesPerWeek(let count):
            String(format: AppLocalization.localizedString("habit.frequency.timesPerWeek"), count)
        }
    }

    static func periodTitle(_ period: HabitGridPeriod) -> String {
        switch period {
        case .weekly: AppLocalization.localizedString("grid.period.weekly")
        case .monthly: AppLocalization.localizedString("grid.period.monthly")
        case .quarterly: AppLocalization.localizedString("grid.period.quarterly")
        }
    }

    static func appearanceTitle(_ appearance: HabitAppearance) -> String {
        switch appearance {
        case .system: AppLocalization.localizedString("settings.appearance.system")
        case .light: AppLocalization.localizedString("settings.appearance.light")
        case .dark: AppLocalization.localizedString("settings.appearance.dark")
        }
    }
}
