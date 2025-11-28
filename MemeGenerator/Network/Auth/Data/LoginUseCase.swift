//
//  LoginUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import Foundation

protocol LoginUseCase {
    func execute(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    )
}

final class LoginUseCaseImpl: LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    ) {
        repository.login(email: email, password: password, completion: completion)
    }
}
