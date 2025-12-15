//
//  RegisterStartData.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

struct RegisterStartData: Codable {
    let requiresEmailVerification: Bool
    let email: String
}
