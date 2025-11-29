//
//  RegisterUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import Foundation

protocol RegisterUseCase {
    func execute(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    )
}

final class RegisterUseCaseImpl: RegisterUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        password: String,
        completion: @escaping (Result<AuthSession, AuthError>) -> Void
    ) {
        repository.register(email: email, password: password, completion: completion)
    }
}
