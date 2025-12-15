//
//  ResetPasswordUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 15.12.25.
//

protocol ResetPasswordUseCase {
    func execute(email: String, otp: String, newPassword: String, completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void)
}
