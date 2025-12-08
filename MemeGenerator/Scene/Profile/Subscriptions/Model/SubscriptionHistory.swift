//
//  SubscriptionHistory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 08.12.25.
//

import Foundation

struct SubscriptionHistory: Codable, Sendable  {
    let success: Bool?
    let data: SubscriptionEvents?
}

struct SubscriptionEvents: Codable, Sendable  {
    let events: [SubscriptionEvent]?
}

struct SubscriptionEvent: Codable, Sendable {
    let id, type, plan: String?
    let isActive: Bool?
    let productID, entitlementID, source, date: String?
    let expiresAt: String?
}
