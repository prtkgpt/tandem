import Foundation

struct DateNight: Codable, Identifiable {
    let id: String
    let status: String  // planning, scheduled, completed
    let agreedIdea: String?
    let agreedBudget: Double?
    let scheduledDate: String?
    let ideas: [DateIdea]
    let createdAt: String
}

struct DateIdea: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let idea: String
    let budget: Double?
}
