import Foundation

struct Couple: Codable {
    let id: String
    let relationshipStartDate: String?
    let weeklyGoalHours: Int
    let subscriptionStatus: String
    let createdAt: String
}
