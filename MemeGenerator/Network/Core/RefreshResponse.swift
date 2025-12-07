//
//  RefreshResponse.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 07.12.25.
//

import Foundation

struct RefreshResponse: @preconcurrency Decodable, Sendable {
    let success: Bool
    let data: AuthRefresh
}

struct AuthRefresh: Decodable, Sendable  {
    let user: User
    let accessToken: String
    let refreshToken: String
}
