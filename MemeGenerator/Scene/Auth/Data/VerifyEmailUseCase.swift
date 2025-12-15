//
//  VerifyEmailUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation

protocol VerifyEmailUseCase {
    func execute(email: String, code: String,
                 completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void)
}
