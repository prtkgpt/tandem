import Foundation

struct CoupleEvent: Codable, Identifiable {
    let id: String
    let title: String
    let emoji: String
    let eventDate: String
    let eventType: String
    let notes: String?
    let createdByUserId: String
    let createdByName: String
    let createdAt: String
}
