//
//  VerifyEmailViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation
import RevenueCat

final class VerifyEmailViewModel: BaseViewModel {

    let email: String

    var onVerified: ((String) -> Void)?

    private let verifyUseCase: VerifyEmailUseCase
    private let resendUseCase: ResendEmailCodeUseCase

    init(
        email: String,
        verifyUseCase: VerifyEmailUseCase,
        resendUseCase: ResendEmailCodeUseCase
    ) {
        self.email = email
        self.verifyUseCase = verifyUseCase
        self.resendUseCase = resendUseCase
        super.init()
    }

    func verify(code: String) {
        let clean = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard clean.count == 6, clean.allSatisfy({ $0.isNumber }) else {
            showError("Please enter 6-digit code.")
            return
        }

        performWithLoading(
            operation: { [weak self] (completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void) in
                guard let self else { return }
                self.verifyUseCase.execute(email: self.email, code: clean, completion: completion)
            },
            errorMapper: { [weak self] error in
                self?.decodeServerMessageFromAuthError(error) ?? "Something went wrong."
            },
            onSuccess: { [weak self] session in
                guard let self else { return }

                AppStorage.shared.saveLogin(
                    accessToken: session.data.accessToken,
                    userId: session.data.user.id,
                    refreshToken: session.data.refreshToken,
                    user: session.data.user
                )

                Purchases.shared.logIn(session.data.user.id) { _, created, error in
                    if let error { print("RevenueCat logIn error:", error) }
                    else { print("RevenueCat logIn ok, created =", created) }
                }

                self.showSuccess("Email verified ✅")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onVerified?(session.data.accessToken)
                }
            }
        )
    }

    func resendCode() {
        performWithLoading(
            operation: { [weak self] (completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void) in
                guard let self else { return }
                self.resendUseCase.execute(email: self.email, completion: completion)
            },
            errorMapper: { [weak self] error in
                self?.decodeServerMessageFromAuthError(error) ?? "Please try again."
            },
            onSuccess: { [weak self] response in
                self?.showSuccess(response.message ?? "Code sent.")
            }
        )
    }

    private func decodeServerMessageFromAuthError(_ error: AuthError) -> String {
        switch error {
        case .server(let raw):
            return decodeServerMessage(raw)
        case .network(let msg):
            return msg
        case .invalidCredentials:
            return "Invalid code."
        case .decoding:
            return "Unexpected response."
        case .unknown:
            return "Something went wrong."
        }
    }
}
