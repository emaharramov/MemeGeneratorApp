//
//  VerifyEmailUseCaseImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

final class VerifyEmailUseCaseImpl: VerifyEmailUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        code: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    ) {
        repository.verifyEmail(email: email, code: code, completion: completion)
    }
}
