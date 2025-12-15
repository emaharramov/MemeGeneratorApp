//
//  ForgotPasswordUseCaseImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

final class ForgotPasswordUseCaseImpl: ForgotPasswordUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void) {
        repository.forgotPassword(email: email, completion: completion)
    }
}
