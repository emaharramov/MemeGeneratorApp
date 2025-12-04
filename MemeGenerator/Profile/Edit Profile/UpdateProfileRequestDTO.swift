//
//  UpdateProfileRequestDTO.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 04.12.25.
//

struct UpdateProfileRequestDTO: Encodable {
    let fullName: String
    let username: String
    let email: String
}
