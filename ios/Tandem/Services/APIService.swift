import Foundation

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .unauthorized: return "Please sign in again"
        case .serverError(let msg): return msg
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
}

// MARK: - API Service

class APIService {
    static let shared = APIService()

    private let baseURL = "https://tandem-livid.vercel.app"
    private var authToken: String? {
        get { KeychainHelper.get(key: "authToken") }
        set {
            if let val = newValue { KeychainHelper.set(key: "authToken", value: val) }
            else { KeychainHelper.delete(key: "authToken") }
        }
    }

    private init() {}

    // MARK: - Authentication State

    var isAuthenticated: Bool {
        return authToken != nil
    }

    func setToken(_ token: String) {
        authToken = token
    }

    func clearToken() {
        authToken = nil
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(
        method: String,
        path: String,
        body: [String: Any]? = nil,
        authenticated: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.serverError("Request failed with status \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Auth

    func register(name: String, email: String, password: String, inviteCode: String? = nil) async throws -> AuthResponse {
        var body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        if let code = inviteCode {
            body["inviteCode"] = code
        }
        return try await request(
            method: "POST",
            path: "/api/auth/register",
            body: body,
            authenticated: false
        )
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        return try await request(
            method: "POST",
            path: "/api/auth/login",
            body: [
                "email": email,
                "password": password
            ],
            authenticated: false
        )
    }

    func getMe() async throws -> MeResponse {
        return try await request(
            method: "GET",
            path: "/api/me"
        )
    }

    // MARK: - Partner

    func validateCode(code: String) async throws -> ValidateCodeResponse {
        return try await request(
            method: "POST",
            path: "/api/partner/validate-code",
            body: ["code": code],
            authenticated: false
        )
    }

    func createInvite() async throws -> InviteResponse {
        return try await request(
            method: "POST",
            path: "/api/partner/invite"
        )
    }

    func joinPartner(code: String) async throws -> JoinResponse {
        return try await request(
            method: "POST",
            path: "/api/partner/join",
            body: ["code": code]
        )
    }

    // MARK: - Topics

    func getTodayTopic() async throws -> TopicWrapper {
        return try await request(
            method: "GET",
            path: "/api/topics"
        )
    }

    func respondToTopic(text: String) async throws -> TopicWrapper {
        return try await request(
            method: "POST",
            path: "/api/topics/respond",
            body: ["text": text]
        )
    }

    // MARK: - Appreciations

    func getAppreciations() async throws -> AppreciationsWrapper {
        return try await request(
            method: "GET",
            path: "/api/appreciations"
        )
    }

    func createAppreciation(message: String) async throws -> AppreciationWrapper {
        return try await request(
            method: "POST",
            path: "/api/appreciations",
            body: ["message": message]
        )
    }

    // MARK: - Our Time

    func getTimeLogs() async throws -> TimeLogsWrapper {
        return try await request(
            method: "GET",
            path: "/api/our-time"
        )
    }

    func logTime(activityName: String, durationMinutes: Int, date: String? = nil) async throws -> TimeLogWrapper {
        var body: [String: Any] = [
            "activityName": activityName,
            "durationMinutes": durationMinutes
        ]
        if let date = date {
            body["date"] = date
        }
        return try await request(
            method: "POST",
            path: "/api/our-time",
            body: body
        )
    }

    // MARK: - Date Nights

    func getDateNights() async throws -> DateNightsWrapper {
        return try await request(
            method: "GET",
            path: "/api/date-nights"
        )
    }

    func createDateNight() async throws -> DateNightWrapper {
        return try await request(
            method: "POST",
            path: "/api/date-nights"
        )
    }

    func submitIdeas(dateNightId: String, ideas: [[String: Any]]) async throws -> DateNightWrapper {
        return try await request(
            method: "POST",
            path: "/api/date-nights/\(dateNightId)",
            body: ["ideas": ideas]
        )
    }

    func updateDateNight(
        id: String,
        agreedIdea: String? = nil,
        agreedBudget: Double? = nil,
        scheduledDate: String? = nil,
        status: String? = nil
    ) async throws -> DateNightWrapper {
        var body: [String: Any] = [:]
        if let agreedIdea = agreedIdea { body["agreedIdea"] = agreedIdea }
        if let agreedBudget = agreedBudget { body["agreedBudget"] = agreedBudget }
        if let scheduledDate = scheduledDate { body["scheduledDate"] = scheduledDate }
        if let status = status { body["status"] = status }

        return try await request(
            method: "PATCH",
            path: "/api/date-nights/\(id)",
            body: body
        )
    }

    // MARK: - Goals

    func getGoals() async throws -> GoalsWrapper {
        return try await request(
            method: "GET",
            path: "/api/goals"
        )
    }

    func createGoal(name: String, targetAmount: Double, emoji: String? = nil) async throws -> GoalWrapper {
        var body: [String: Any] = [
            "name": name,
            "targetAmount": targetAmount
        ]
        if let emoji = emoji { body["emoji"] = emoji }

        return try await request(
            method: "POST",
            path: "/api/goals",
            body: body
        )
    }

    func contribute(goalId: String, amount: Double) async throws -> GoalWrapper {
        return try await request(
            method: "POST",
            path: "/api/goals/\(goalId)/contribute",
            body: ["amount": amount]
        )
    }

    // MARK: - Stats

    func getStats() async throws -> CoupleStats {
        let wrapper: StatsWrapper = try await request(
            method: "GET",
            path: "/api/us/stats"
        )
        return wrapper.stats
    }

    func getWeeklySummary() async throws -> WeeklySummaryWrapper {
        return try await request(
            method: "GET",
            path: "/api/weekly-summary"
        )
    }
}

// MARK: - Response Wrapper Structs

struct MeResponse: Codable {
    let user: TandemUser
    let couple: Couple?
    let partnerName: String?
}

struct JoinResponse: Codable {
    let coupleId: String
    let partnerName: String
}

struct TopicWrapper: Codable {
    let topic: TableTopic?
}

struct AppreciationsWrapper: Codable {
    let appreciations: [Appreciation]
}

struct AppreciationWrapper: Codable {
    let appreciation: Appreciation
}

struct TimeLogsWrapper: Codable {
    let timeLogs: [OurTimeLog]
}

struct TimeLogWrapper: Codable {
    let timeLog: OurTimeLog
}

struct DateNightsWrapper: Codable {
    let dateNights: [DateNight]
}

struct DateNightWrapper: Codable {
    let dateNight: DateNight
}

struct GoalsWrapper: Codable {
    let goals: [SavingsGoal]
}

struct GoalWrapper: Codable {
    let goal: SavingsGoal
}

private struct StatsWrapper: Codable {
    let stats: CoupleStats
}

struct WeeklySummaryWrapper: Codable {
    let summary: WeeklySummary?
}
