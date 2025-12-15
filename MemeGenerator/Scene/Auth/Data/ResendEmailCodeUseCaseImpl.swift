//
//  ResendEmailCodeUseCaseImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

final class ResendEmailCodeUseCaseImpl: ResendEmailCodeUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void
    ) {
        repository.resendEmailCode(email: email, completion: completion)
    }
}
