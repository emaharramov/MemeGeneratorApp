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
        username: String,
        password: String,
        completion: @escaping (Result<RegisterStartResponseModel, AuthError>) -> Void
    )
}

final class RegisterUseCaseImpl: RegisterUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<RegisterStartResponseModel, AuthError>) -> Void
    ) {
        repository.register(
            email: email,
            username: username,
            password: password,
            completion: completion
        )
    }
}
