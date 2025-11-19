//
//  AuthViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class AuthViewModel: BaseViewModel {

    var onLoginSuccess: ((String) -> Void)?
    var onRegisterSuccess: ((String) -> Void)?

    // MARK: - Validation
    private func validate(_ email: String, _ password: String) -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            setError("Please enter email.")
            return false
        }
        guard !password.isEmpty else {
            setError("Please enter password.")
            return false
        }
        return true
    }

    // MARK: - Login
    func login(email: String, password: String) {
        guard validate(email, password) else { return }

        setLoading(true)
        resetErrors()

        AuthManager.shared.login(email: email, password: password) { [weak self] model, error in
            guard let self else { return }
            self.setLoading(false)

            if let error {
                self.setError(error)
                return
            }

            guard let token = model?.token, let userId = model?.userId else {
                self.setError("Invalid credentials.")
                return
            }

            self.setSuccess("Login successful!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.onLoginSuccess?(token)
                AppStorage.shared.userId = userId
            }
        }
    }

    // MARK: - Register
    func register(email: String, password: String) {
        guard validate(email, password) else { return }

        setLoading(true)
        resetErrors()

        AuthManager.shared.register(email: email, password: password) { [weak self] model, error in
            guard let self else { return }
            self.setLoading(false)

            if let error {
                self.setError(error)
                return
            }

            guard let token = model?.token, let userId = model?.userId else {
                self.setError("Invalid token.")
                return
            }

            self.setSuccess("Registration successful!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.onRegisterSuccess?(token)
                AppStorage.shared.userId = userId
            }
        }
    }
}
