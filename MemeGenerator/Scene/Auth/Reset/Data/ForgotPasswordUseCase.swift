//
//  ForgotPasswordUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

protocol ForgotPasswordUseCase {
    func execute(email: String, completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void)
}
