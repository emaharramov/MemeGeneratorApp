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
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            setError("Please enter email and password.")
            return false
        }
        return true
    }

    // MARK: - Login
    func login(email: String, password: String) {
        guard validate(email, password) else { return }

        setError(nil)
        setLoading(true)

        AuthManager.shared.login(email: email, password: password) { [weak self] model, error in
            guard let self else { return }
            self.setLoading(false)

            if let error = error {
                self.setError(error)
                return
            }

            guard let token = model?.token else {
                self.setError("Invalid email.")
                print("token::", model?.token)
                return
            }

            self.onLoginSuccess?(token)
        }
    }

    // MARK: - Register
    func register(email: String, password: String) {
        guard validate(email, password) else { return }

        setError(nil)
        setLoading(true)

        AuthManager.shared.register(email: email, password: password) { [weak self] model, error in
            guard let self else { return }
            self.setLoading(false)

            if let error = error {
                self.setError(error)
                return
            }

            guard let token = model?.token else {
                self.setError("Invalid token.")
                print("token::", model?.token)
                return
            }

            self.onRegisterSuccess?(token)
        }
    }
}
