import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case englishUS = "english"
    case japanese
    case german
    case englishUK
    case englishCanada
    case frenchFrance = "french"
    case chineseTraditional
    case chineseSimplified
    case thai
    case korean

    static var allCases: [AppLanguage] {
        [
            .englishUS,
            .german,
            .englishUK,
            .englishCanada,
            .japanese,
            .chineseSimplified,
            .chineseTraditional,
            .thai,
            .frenchFrance,
            .korean
        ]
    }

    static let storageKey = "app.language"

    var id: String { rawValue }

    static func selected(from rawValue: String?) -> AppLanguage {
        let language = rawValue.flatMap(AppLanguage.init(rawValue:)) ?? .englishUS
        return language == .system ? .englishUS : language
    }

    var titleKey: String {
        switch self {
        case .system: "settings.language.system"
        case .englishUS: "settings.language.englishUS"
        case .german: "settings.language.german"
        case .englishUK: "settings.language.englishUK"
        case .englishCanada: "settings.language.englishCanada"
        case .japanese: "settings.language.japanese"
        case .chineseSimplified: "settings.language.chineseSimplified"
        case .chineseTraditional: "settings.language.chineseTraditional"
        case .thai: "settings.language.thai"
        case .frenchFrance: "settings.language.frenchFrance"
        case .korean: "settings.language.korean"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .englishUS:
            Locale(identifier: "en-US")
        case .german:
            Locale(identifier: "de")
        case .englishUK:
            Locale(identifier: "en-GB")
        case .englishCanada:
            Locale(identifier: "en-CA")
        case .japanese:
            Locale(identifier: "ja")
        case .chineseSimplified:
            Locale(identifier: "zh-Hans")
        case .chineseTraditional:
            Locale(identifier: "zh-Hant")
        case .thai:
            Locale(identifier: "th")
        case .frenchFrance:
            Locale(identifier: "fr-FR")
        case .korean:
            Locale(identifier: "ko")
        }
    }

    var bundleLanguageCode: String? {
        switch self {
        case .system: nil
        case .englishUS: "en-US"
        case .german: "de"
        case .englishUK: "en-GB"
        case .englishCanada: "en-CA"
        case .japanese: "ja"
        case .chineseSimplified: "zh-Hans"
        case .chineseTraditional: "zh-Hant"
        case .thai: "th"
        case .frenchFrance: "fr-FR"
        case .korean: "ko"
        }
    }
}

enum AppLocalization {
    static var selectedLocale: Locale {
        selectedLanguage.locale
    }

    static func localizedString(_ key: String) -> String {
        let language = selectedLanguage

        guard
            let languageCode = language.bundleLanguageCode,
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        }

        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    static func formattedDate(
        _ date: Date,
        dateStyle: DateFormatter.Style = .none,
        timeStyle: DateFormatter.Style = .none,
        template: String? = nil
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = selectedLocale
        if let template {
            formatter.setLocalizedDateFormatFromTemplate(template)
        } else {
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
        }
        return formatter.string(from: date)
    }

    static func monthAbbreviation(_ date: Date) -> String {
        formattedDate(date, template: "MMM")
    }

    static func monthDay(_ date: Date) -> String {
        formattedDate(date, template: "MMM d")
    }

    static func monthYear(_ date: Date, abbreviated: Bool = false) -> String {
        formattedDate(date, template: abbreviated ? "MMM y" : "MMMM y")
    }

    static func weekdayAbbreviation(_ date: Date) -> String {
        formattedDate(date, template: "EEE")
    }

    static func fullDate(_ date: Date) -> String {
        formattedDate(date, dateStyle: .full)
    }

    private static var selectedLanguage: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: AppLanguage.storageKey) ?? AppLanguage.englishUS.rawValue
        return AppLanguage.selected(from: rawValue)
    }
}
