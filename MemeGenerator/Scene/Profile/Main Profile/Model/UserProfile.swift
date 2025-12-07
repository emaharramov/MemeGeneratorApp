//
//  UserProfile.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

// MARK: - UserProfileResponse
struct UserProfile: Codable {
    let success: Bool
    let data: UserProfileData
}

// MARK: - UserProfileData
struct UserProfileData: Codable {
    let user: User
    let stats: Stats?
    let usage: Usage?
    let settings: Settings?
    let createdAt: String?
    let updatedAt: String?
}

struct Settings: Codable {
    let language: String?
    let theme: String?
}

struct Stats: Codable {
    let aiMemeCount: Int?
    let aiTemplateMemeCount: Int?
}

struct Usage: Codable {
    let ai: AI?
}

struct AI: Codable {
    let limit: Int?
    let used: Int?
    let periodStart: String?
}
