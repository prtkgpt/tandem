import Foundation

struct WeeklySummary: Codable, Identifiable {
    let id: String
    let weekStartDate: String
    let totalTimeMinutes: Int
    let totalAppreciations: Int
    let wins: [String]
    let nudge: String?
    let createdAt: String
}
