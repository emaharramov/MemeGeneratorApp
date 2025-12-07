//
//  User.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 07.12.25.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let username: String
    let fullName: String?
    let avatarUrl: String?
    let isPremium: Bool
    let premiumPlan: String?
    let premiumExpiresAt: String?
}
