import Foundation

struct Appreciation: Codable, Identifiable {
    let id: String
    let fromUserId: String
    let fromUserName: String
    let message: String
    let createdAt: String
}
