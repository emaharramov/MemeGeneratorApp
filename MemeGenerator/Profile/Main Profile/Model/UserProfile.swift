//
//  UserProfile.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct UserProfile: Codable {
    let success: Bool?
    let data: DataClass?
}

struct DataClass: Codable {
    let user: User?
    let stats: Stats?
    let usage: Usage?
    let settings: Settings?
    let createdAt, updatedAt: String?
}

struct Settings: Codable {
    let language, theme: String?
}

struct Stats: Codable {
    let aiMemeCount, aiTemplateMemeCount: Int?
}

struct Usage: Codable {
    let ai: AI?
}

struct AI: Codable {
    let limit, used: Int?
    let periodStart: String?
}

struct User: Codable {
    let id, email, username, fullName: String?
    let avatarUrl: String?
    let isPremium: Bool?
    let premiumPlan: String?
    let premiumExpiresAt: String?
}
