//
//  AuthViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

final class AuthViewModel: BaseViewModel {

    var onLoginSuccess: ((String) -> Void)?
    var onRegisterSuccess: ((String) -> Void)?

    private let loginUseCase: LoginUseCase
    private let registerUseCase: RegisterUseCase

    init(
        loginUseCase: LoginUseCase,
        registerUseCase: RegisterUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
    }

    // MARK: - Validation
    private func validate(_ email: String, _ password: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            setError("Please enter email.")
            return false
        }
        guard !password.isEmpty else {
            setError("Please enter password.")
            return false
        }
        // Burada istəsən email regex də əlavə edərsən
        return true
    }

    // MARK: - Login
    func login(email: String, password: String) {
        guard validate(email, password) else { return }

        setLoading(true)
        resetErrors()

        loginUseCase.execute(email: email, password: password) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case .success(let session):
                AppStorage.shared.saveLogin(token: session.token,
                                            userId: session.userId)

                self.setSuccess("Login successful!")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onLoginSuccess?(session.token)
                }

            case .failure(let error):
                let message = self.mapError(error)
                self.setError(message)
            }
        }
    }

    func register(email: String, password: String) {
        guard validate(email, password) else { return }

        setLoading(true)
        resetErrors()

        registerUseCase.execute(email: email, password: password) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case .success(let session):
                AppStorage.shared.saveLogin(token: session.token,
                                            userId: session.userId)

                self.setSuccess("Registration successful!")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onRegisterSuccess?(session.token)
                }

            case .failure(let error):
                let message = self.mapError(error)
                self.setError(message)
            }
        }
    }

    private func mapError(_ error: AuthError) -> String {
        switch error {
        case .invalidCredentials:
            return "Invalid email or password."

        case .network(let message):
            return message

        case .server(let message):
            return message

        case .decoding:
            return "Unexpected response from server."

        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
