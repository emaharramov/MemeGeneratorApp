//
//  AuthRegisterRequestModel..swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct AuthRegisterRequestModel: AuthRequestModel {
    let email: String
    let username: String
    let password: String
}
