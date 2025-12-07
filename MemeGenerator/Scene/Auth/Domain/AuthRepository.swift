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
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    )
}
