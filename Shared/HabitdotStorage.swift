import Foundation

enum HabitdotStorage {
    static let appGroupIdentifier = "group.com.sikgates.habitdotapp"
    private static let fileName = "habitdot-snapshot.json"

    static func load() -> HabitSnapshot {
        guard let url = snapshotURL(), FileManager.default.fileExists(atPath: url.path) else {
            return .empty
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(HabitSnapshot.self, from: data)
        } catch {
            return .empty
        }
    }

    static func save(_ snapshot: HabitSnapshot) {
        guard let url = snapshotURL() else { return }

        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(snapshot)
            try data.write(to: url, options: .atomic)
            HabitdotSyncNotification.postSnapshotDidChange()
        } catch {
            assertionFailure("Failed to save Habitdot snapshot: \(error)")
        }
    }

    private static func snapshotURL() -> URL? {
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return groupURL.appendingPathComponent(fileName)
        }

        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }
}
