import Foundation
import UserNotifications

enum HabitReminderScheduler {
    private static let commonIdentifier = "habitdot.reminder.common"
    private static let habitIdentifierPrefix = "habitdot.reminder.habit."

    static func sync(snapshot: HabitSnapshot) {
        Task {
            await syncReminders(snapshot: snapshot)
        }
    }

    @discardableResult
    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        switch await authorizationStatus(center: center) {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await requestAuthorization(center: center)) == true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private static func syncReminders(snapshot: HabitSnapshot) async {
        let center = UNUserNotificationCenter.current()
        guard await hasAuthorization(center: center) else { return }

        let existingIdentifiers = await pendingNotificationRequestIdentifiers(center: center)
            .filter { $0 == commonIdentifier || $0.hasPrefix(habitIdentifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: existingIdentifiers)

        var requests: [UNNotificationRequest] = []

        if
            let hour = snapshot.settings.commonReminderHour,
            let minute = snapshot.settings.commonReminderMinute
        {
            requests.append(commonReminderRequest(hour: hour, minute: minute))
        }

        requests.append(contentsOf: snapshot.activeHabits.compactMap(habitReminderRequest))

        for request in requests {
            try? await add(request, center: center)
        }
    }

    private static func commonReminderRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = AppLocalization.localizedString("notification.common.title")
        content.body = AppLocalization.localizedString(commonTemplateKeys.randomElement() ?? commonTemplateKeys[0])
        content.sound = .default
        content.threadIdentifier = "habitdot.common"

        return UNNotificationRequest(
            identifier: commonIdentifier,
            content: content,
            trigger: dailyTrigger(hour: hour, minute: minute)
        )
    }

    private static func habitReminderRequest(for habit: Habit) -> UNNotificationRequest? {
        guard let hour = habit.reminderHour, let minute = habit.reminderMinute else { return nil }

        let content = UNMutableNotificationContent()
        content.title = String(format: AppLocalization.localizedString("notification.habit.title"), habit.title)
        content.body = String(format: AppLocalization.localizedString(habitTemplateKeys.randomElement() ?? habitTemplateKeys[0]), habit.title)
        content.sound = .default
        content.threadIdentifier = "habitdot.habit"

        return UNNotificationRequest(
            identifier: habitIdentifierPrefix + habit.id,
            content: content,
            trigger: dailyTrigger(hour: hour, minute: minute)
        )
    }

    private static func dailyTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var components = DateComponents()
        components.hour = min(max(hour, 0), 23)
        components.minute = min(max(minute, 0), 59)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }

    private static func hasAuthorization(center: UNUserNotificationCenter) async -> Bool {
        switch await authorizationStatus(center: center) {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }

    private static func authorizationStatus(center: UNUserNotificationCenter) async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    private static func requestAuthorization(center: UNUserNotificationCenter) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    private static func pendingNotificationRequestIdentifiers(center: UNUserNotificationCenter) async -> [String] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests.map(\.identifier))
            }
        }
    }

    private static func add(_ request: UNNotificationRequest, center: UNUserNotificationCenter) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private static let commonTemplateKeys = [
        "notification.common.template.1",
        "notification.common.template.2",
        "notification.common.template.3",
        "notification.common.template.4",
        "notification.common.template.5",
        "notification.common.template.6",
        "notification.common.template.7",
        "notification.common.template.8",
        "notification.common.template.9",
        "notification.common.template.10"
    ]

    private static let habitTemplateKeys = [
        "notification.habit.template.1",
        "notification.habit.template.2",
        "notification.habit.template.3",
        "notification.habit.template.4",
        "notification.habit.template.5",
        "notification.habit.template.6",
        "notification.habit.template.7",
        "notification.habit.template.8",
        "notification.habit.template.9",
        "notification.habit.template.10"
    ]
}
