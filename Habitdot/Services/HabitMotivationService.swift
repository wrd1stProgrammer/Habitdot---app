import Foundation

struct HabitMotivationDayPayload: Codable, Hashable {
    let date: String
    let completed: Bool
    let count: Int
}

struct HabitMotivationHabitPayload: Codable, Hashable {
    let title: String
    let purpose: String?
    let colorHex: String?
    let completedToday: Bool
    let completedYesterday: Bool
    let currentStreak: Int
    let weeklyCompletionCount: Int
    let recent7Days: [HabitMotivationDayPayload]

    enum CodingKeys: String, CodingKey {
        case title
        case purpose
        case colorHex = "color_hex"
        case completedToday = "completed_today"
        case completedYesterday = "completed_yesterday"
        case currentStreak = "current_streak"
        case weeklyCompletionCount = "weekly_completion_count"
        case recent7Days = "recent_7_days"
    }
}

struct HabitMotivationRequest: Codable, Hashable {
    let locale: String
    let date: String
    let habits: [HabitMotivationHabitPayload]
}

struct HabitMotivationResponse: Codable, Hashable {
    let text: String
    let provider: String
    let modelName: String?
    let generatedAt: Date

    enum CodingKeys: String, CodingKey {
        case text
        case provider
        case modelName = "model_name"
        case generatedAt = "generated_at"
    }
}

@MainActor
struct HabitMotivationService {
    private let endpoint = URL(string: "https://facemaxx.nostalgia-drive.com/v1/habitdot/motivation")!
    private let session: URLSession
    private let userDefaults: UserDefaults
    private let cacheKey = "habitdot.dailyMotivationCache"

    init(session: URLSession = .shared, userDefaults: UserDefaults = .standard) {
        self.session = session
        self.userDefaults = userDefaults
    }

    func cachedResponse(for request: HabitMotivationRequest) -> HabitMotivationResponse? {
        guard
            let data = userDefaults.data(forKey: cacheKey),
            let entry = try? Self.decoder.decode(CacheEntry.self, from: data),
            entry.requestKey == request.cacheIdentity
        else { return nil }
        return entry.response
    }

    func fetchResponse(for requestBody: HabitMotivationRequest) async throws -> HabitMotivationResponse {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 8
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(HabitdotInstallIdentity.value(userDefaults: userDefaults), forHTTPHeaderField: "X-Facemaxx-Install-Id")
        urlRequest.httpBody = try Self.encoder.encode(requestBody)

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try Self.decoder.decode(HabitMotivationResponse.self, from: data)
        save(decoded, for: requestBody)
        return decoded
    }

    private func save(_ response: HabitMotivationResponse, for request: HabitMotivationRequest) {
        let entry = CacheEntry(requestKey: request.cacheIdentity, response: response)
        guard let data = try? Self.encoder.encode(entry) else { return }
        userDefaults.set(data, forKey: cacheKey)
    }

    private struct CacheEntry: Codable {
        let requestKey: String
        let response: HabitMotivationResponse
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension HabitMotivationRequest {
    var cacheIdentity: String {
        "daily|\(date)"
    }
}
