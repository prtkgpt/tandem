import Foundation

struct AuthResponse: Codable {
    let token: String
    let user: TandemUser
    let paired: Bool?
    let partnerName: String?
}

struct InviteResponse: Codable {
    let code: String
    let expiresAt: String
}

struct ValidateCodeResponse: Codable {
    let valid: Bool
    let senderName: String
}

// Note: APIError enum and ErrorResponse struct are defined in APIService.swift
