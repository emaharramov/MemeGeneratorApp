//
//  AuthLoginResponseModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct AuthLoginResponseModel: Codable {
    let success: Bool
    let data: AuthLoginData
}

struct AuthLoginData: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}
