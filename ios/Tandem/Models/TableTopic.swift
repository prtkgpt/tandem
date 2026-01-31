import Foundation

struct TableTopic: Codable, Identifiable {
    let id: String
    let questionText: String
    let category: String
    let askedDate: String
    let responses: [TopicResponse]
    let bothResponded: Bool
}

struct TopicResponse: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let text: String
    let createdAt: String
}
