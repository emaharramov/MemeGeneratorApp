//
//  SyncPremiumRequestDTO.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 08.12.25.
//

struct SyncPremiumRequestDTO {
    let userId: String
    let entitlementId: String
    let productId: String
    let isActive: Bool
    let expiresAt: String?
}
