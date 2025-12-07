//
//  UpdateProfileRequestDTO.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 04.12.25.
//

import Foundation

struct UpdateProfileRequestDTO: Encodable {
    let avatarUrl: String
    let fullName: String
    let username: String
    let email: String
}
