import Foundation

struct TandemUser: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let coupleId: String?
    let notificationHour: Int
    let notificationMin: Int
    let createdAt: String
}
