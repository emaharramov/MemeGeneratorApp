//
//  ResetPasswordUseCaseImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 15.12.25.
//

final class ResetPasswordUseCaseImpl: ResetPasswordUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, otp: String, newPassword: String, completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void) {
        repository.resetPassword(email: email, code: otp, newPassword: newPassword, completion: completion)
    }
}
