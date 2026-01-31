import Foundation

struct OurTimeLog: Codable, Identifiable {
    let id: String
    let activityName: String
    let durationMinutes: Int
    let date: String
    let loggedByName: String
    let createdAt: String
}
