//
//  AuthViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import RevenueCat

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

    private func validate(_ email: String, username: String? = nil, _ password: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showError("Please enter email.")
            return false
        }
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)

        guard predicate.evaluate(with: trimmed) else {
            showError("Please enter a valid email address.")
            return false
        }
        guard !password.isEmpty else {
            showError("Please enter password.")
            return false
        }

        return true
    }

    func login(email: String, password: String) {
        guard validate(email, password) else { return }

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.loginUseCase.execute(
                    email: email,
                    password: password,
                    completion: completion
                )
            },
            errorMapper: { [weak self] error in
                self?.mapError(error) ?? "Something went wrong. Please try again."
            },
            onSuccess: { [weak self] (session: AuthLoginResponseModel)in
                guard let self else { return }

                AppStorage.shared.saveLogin(
                    accessToken: session.accessToken,
                    userId: session.userId,
                    refreshToken: session.refreshToken
                )
                Purchases.shared.logIn(session.userId) { customerInfo, created, error in
                    if let error {
                        print("RevenueCat logIn error:", error)
                    } else {
                        print("RevenueCat logIn ok, created =", created)
                    }
                }
                self.showSuccess("Login successful!")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onLoginSuccess?(session.accessToken)
                }
            }
        )
    }

    func register(email: String, username: String, password: String) {
        guard validate(email, username: username, password) else { return }

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.registerUseCase.execute(
                    email: email,
                    username: username,
                    password: password,
                    completion: completion
                )
            },
            errorMapper: { [weak self] error in
                self?.mapError(error) ?? "Something went wrong. Please try again."
            },
            onSuccess: { [weak self] (session: AuthLoginResponseModel) in
                guard let self else { return }

                AppStorage.shared.saveLogin(
                    accessToken: session.accessToken,
                    userId: session.userId,
                    refreshToken: session.refreshToken
                )
                Purchases.shared.logIn(session.userId) { customerInfo, created, error in
                    if let error {
                        print("RevenueCat logIn error:", error)
                    } else {
                        print("RevenueCat logIn ok, created =", created)
                    }
                }

                self.showSuccess("Registration successful!")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onRegisterSuccess?(session.accessToken)
                }
            }
        )
    }

    private func mapError(_ error: AuthError) -> String {
        struct ServerErrorResponse: Decodable {
            let success: Bool?
            let message: String?
        }

        switch error {
        case .invalidCredentials:
            return "Email or password incorrect."

        case .network(let message):
            return message

        case .server(let rawMessage):
            if let data = rawMessage.data(using: .utf8),
               let parsed = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
               let msg = parsed.message,
               !msg.isEmpty {
                return msg
            }

            if !rawMessage.isEmpty {
                return rawMessage
            } else {
                return "Something went wrong. Please try again."
            }

        case .decoding:
            return "Unexpected response from server."

        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
