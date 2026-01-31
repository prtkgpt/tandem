import Foundation

struct MoodCheckin: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let mood: String
    let note: String?
    let createdAt: String
}
