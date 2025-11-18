//
//  AuthModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

struct AuthModel: Codable {
    let email: String
    let password: String
}

struct AuthLoginModel: Codable {
    let token: String
}
