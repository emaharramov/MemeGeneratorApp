//
//  UserProfile.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct UserProfile: Codable {
    let success: Bool
    let data: UserProfileData
}

struct UserProfileData: Codable {
    let id: String
    let email: String
    let username: String
    let fullName: String
    let avatarUrl: String
    let isPremium: Bool
    let premiumExpiresAt: String?
    let settings: Settings
    let createdAt: String
    let updatedAt: String
}

struct Settings: Codable {
    let language: String
    let theme: String
}
