//
//  AuthLoginResponseModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct AuthLoginResponseModel: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let userId: String
}
