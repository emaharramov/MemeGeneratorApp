//
//  ResetPasswordRequestModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation

struct ResetPasswordRequestModel: AuthRequestModel {
    let email: String
    let code: String
    let newPassword: String
}

