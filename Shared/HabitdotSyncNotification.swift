import Foundation

enum HabitdotSyncNotification {
    static let snapshotDidChangeName = "com.sikgates.habitdotapp.snapshotDidChange"

    static func postSnapshotDidChange() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(snapshotDidChangeName as CFString),
            nil,
            nil,
            true
        )
    }

    static func addSnapshotObserver(
        _ observer: UnsafeMutableRawPointer,
        callback: CFNotificationCallback
    ) {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            callback,
            snapshotDidChangeName as CFString,
            nil,
            .deliverImmediately
        )
    }

    static func removeSnapshotObserver(_ observer: UnsafeMutableRawPointer) {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            CFNotificationName(snapshotDidChangeName as CFString),
            nil
        )
    }
}
