//
//  AuthRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import Foundation

protocol AuthRepository {
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    )

    func register(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<RegisterStartResponseModel, AuthError>) -> Void
    )

    func verifyEmail(
        email: String,
        code: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    )

    func resendEmailCode(
        email: String,
        completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void
    )

    func forgotPassword(
        email: String,
        completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void
    )

    func resetPassword(
        email: String,
        code: String,
        newPassword: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    )
}
