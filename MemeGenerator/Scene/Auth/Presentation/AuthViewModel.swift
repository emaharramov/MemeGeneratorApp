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
    var onRegisterRequiresVerification: ((String) -> Void)?

    private let loginUseCase: LoginUseCase
    private let registerUseCase: RegisterUseCase

    init(loginUseCase: LoginUseCase, registerUseCase: RegisterUseCase) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
    }

    func login(email: String, password: String) {
        let normalizedEmail = normalizeEmail(email)

        guard validateLogin(email: normalizedEmail, password: password) else { return }

        performWithLoading(
            operation: { [weak self] (completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void) in
                guard let self else { return }
                self.loginUseCase.execute(
                    email: normalizedEmail,
                    password: password,
                    completion: completion
                )
            },
            errorMapper: { [weak self] error in
                guard let self else { return "Something went wrong. Please try again." }

                if case .server(let raw) = error,
                   let parsed = self.decodeServerCodeMessage(from: raw),
                   parsed.code == "EMAIL_NOT_VERIFIED" {

                    let msg = parsed.message ?? "Please verify your email first."
                    return msg
                }

                return self.mapError(error)
            },
            onSuccess: { [weak self] (session: AuthLoginResponseModel) in
                guard let self else { return }

                AppStorage.shared.saveLogin(
                    accessToken: session.data.accessToken,
                    userId: session.data.user.id,
                    refreshToken: session.data.refreshToken,
                    user: session.data.user
                )

                Purchases.shared.logIn(session.data.user.id) { _, created, error in
                    if let error {
                        print("RevenueCat logIn error:", error)
                    } else {
                        print("RevenueCat logIn ok, created =", created)
                    }
                }

                self.showSuccess("Login successful!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.onLoginSuccess?(session.data.accessToken)
                }
            }
        )
    }

    func register(email: String, username: String, password: String) {
        let normalizedEmail = normalizeEmail(email)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard validateRegister(email: normalizedEmail, username: trimmedUsername, password: password) else { return }

        performWithLoading(
            operation: { [weak self] (completion: @escaping (Result<RegisterStartResponseModel, AuthError>) -> Void) in
                guard let self else { return }
                self.registerUseCase.execute(
                    email: normalizedEmail,
                    username: trimmedUsername,
                    password: password,
                    completion: completion
                )
            },
            errorMapper: { [weak self] error in
                self?.mapError(error) ?? "Something went wrong. Please try again."
            },
            onSuccess: { [weak self] (res: RegisterStartResponseModel) in
                guard let self else { return }

                self.showSuccess("We sent a verification code to your email.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.onRegisterRequiresVerification?(res.data.email)
                }
            }
        )
    }

    private func validateEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { showError("Please enter email."); return false }

        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        guard predicate.evaluate(with: trimmed) else {
            showError("Please enter a valid email address.")
            return false
        }
        return true
    }

    private func validateLogin(email: String, password: String) -> Bool {
        guard validateEmail(email) else { return false }

        guard password.count >= 8 else {
            showError("Password must be at least 8 characters.")
            return false
        }
        return true
    }

    private func validateRegister(email: String, username: String, password: String) -> Bool {
        guard validateEmail(email) else { return false }

        guard !username.isEmpty else {
            showError("Please enter username.")
            return false
        }

        guard password.count >= 8 else {
            showError("Password must be at least 8 characters.")
            return false
        }
        
        return true
    }

    private func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func decodeServerCodeMessage(from raw: String) -> (code: String?, message: String?)? {
        struct ServerErr: Decodable { let message: String?; let code: String? }
        guard let data = raw.data(using: .utf8),
              let parsed = try? JSONDecoder().decode(ServerErr.self, from: data) else {
            return nil
        }
        return (parsed.code, parsed.message)
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
            return rawMessage.isEmpty ? "Something went wrong. Please try again." : rawMessage

        case .decoding:
            return "Unexpected response from server."

        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
