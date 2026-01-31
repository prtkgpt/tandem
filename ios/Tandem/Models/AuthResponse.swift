import Foundation

struct AuthResponse: Codable {
    let token: String
    let user: TandemUser
}

struct InviteResponse: Codable {
    let code: String
    let expiresAt: String
}

// Note: APIError enum and ErrorResponse struct are defined in APIService.swift
