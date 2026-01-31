import Foundation

struct BoardItem: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    let emoji: String
    let createdByUserId: String
    let createdByName: String
    let claimedByUserId: String?
    let claimedByName: String?
    let isComplete: Bool
    let completedAt: String?
    let createdAt: String
}
