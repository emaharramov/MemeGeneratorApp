//
//  AuthLoginRequestModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct AuthLoginRequestModel: AuthRequestModel {
    let email: String
    let password: String
}
