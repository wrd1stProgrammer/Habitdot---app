import Foundation

struct FeedbackSubmissionRequest: Codable, Hashable {
    let kind: String
    let subject: String
    let message: String
    let locale: String
    let countryCode: String?
    let timeZone: String
    let appVersion: String
    let buildNumber: String
    let platform: String

    enum CodingKeys: String, CodingKey {
        case kind
        case subject
        case message
        case locale
        case countryCode = "country_code"
        case timeZone = "time_zone"
        case appVersion = "app_version"
        case buildNumber = "build_number"
        case platform
    }
}

@MainActor
struct FeedbackSubmissionService {
    private let endpoint: URL
    private let session: URLSession
    private let userDefaults: UserDefaults

    init(
        baseURL: URL = URL(string: "https://facemaxx.nostalgia-drive.com/v1/habitdot")!,
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.endpoint = baseURL
        self.session = session
        self.userDefaults = userDefaults
    }

    func submit(_ requestBody: FeedbackSubmissionRequest) async throws {
        let path = requestBody.kind == "bug" ? "bugs" : "feedback"
        var urlRequest = URLRequest(url: endpoint.appendingPathComponent(path))
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 8
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(HabitdotInstallIdentity.value(userDefaults: userDefaults), forHTTPHeaderField: "X-Facemaxx-Install-Id")
        urlRequest.httpBody = try Self.encoder.encode(requestBody)

        let (_, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
