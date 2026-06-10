import Foundation

struct HabitdotPaywallViewRequest: Codable, Hashable {
    let locale: String
    let countryCode: String?
    let timeZone: String
    let appVersion: String
    let buildNumber: String
    let platform: String

    enum CodingKeys: String, CodingKey {
        case locale
        case countryCode = "country_code"
        case timeZone = "time_zone"
        case appVersion = "app_version"
        case buildNumber = "build_number"
        case platform
    }
}

struct HabitdotPaywallEventService {
    private let endpoint: URL
    private let session: URLSession
    private let userDefaults: UserDefaults

    init(
        baseURL: URL = URL(string: "https://facemaxx.nostalgia-drive.com/v1/habitdot")!,
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.endpoint = baseURL.appendingPathComponent("paywall-view")
        self.session = session
        self.userDefaults = userDefaults
    }

    func recordView() async throws {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 4
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(HabitdotInstallIdentity.value(userDefaults: userDefaults), forHTTPHeaderField: "X-Facemaxx-Install-Id")
        urlRequest.httpBody = try Self.encoder.encode(Self.currentRequest())

        let (_, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }

    private static func currentRequest() -> HabitdotPaywallViewRequest {
        HabitdotPaywallViewRequest(
            locale: Locale.autoupdatingCurrent.identifier,
            countryCode: Locale.autoupdatingCurrent.region?.identifier.uppercased(),
            timeZone: TimeZone.autoupdatingCurrent.identifier,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            platform: "ios"
        )
    }

    private static let encoder = JSONEncoder()
}
