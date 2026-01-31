import Foundation

struct SavingsGoal: Codable, Identifiable {
    let id: String
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let emoji: String
    let contributions: [GoalContribution]
}

struct GoalContribution: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let amount: Double
    let addedAt: String
}
