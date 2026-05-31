import Foundation

enum HabitdotInstallIdentity {
    private static let storageKey = "habitdot.installID"

    static func value(userDefaults: UserDefaults = .standard) -> String {
        if let existing = userDefaults.string(forKey: storageKey) {
            return existing
        }

        let created = UUID().uuidString
        userDefaults.set(created, forKey: storageKey)
        return created
    }
}
