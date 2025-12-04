//
//  AuthLoginResponseModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct AuthLoginResponseModel: Codable {
    let token: String
    let userId: String
}

//struct AuthSession {
//    let token: String
//    let userId: String
//}
