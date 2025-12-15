//
//  VerifyEmailRequestModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

struct VerifyEmailRequestModel: AuthRequestModel {
    let email: String
    let code: String
}
