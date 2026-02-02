//
//  ForgetPasswordVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation
import Combine

enum ForgetPasswordStep: Equatable {
    case enterEmail
    case enterOtp(emailLocked: Bool)
    case enterNewPassword(emailLocked: Bool)
    case loggedIn
}

struct ForgetPasswordViewState: Equatable {
    // Sections
    let showOtpSection: Bool
    let showPasswordSection: Bool
    let emailLocked: Bool

    // Button
    let primaryTitle: String
    let primaryEnabled: Bool

    // Email UI
    let showEmailStatusIcon: Bool

    // OTP UI
    let showOtpHelper: Bool
    let showOtpCheckIcon: Bool

    // Password UI (optional)
    let showPasswordHelper: Bool
}

// MARK: - Validators

enum EmailValidator {
    static func isValid(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return predicate.evaluate(with: trimmed)
    }
}

enum OTPValidator {
    static func isValid(_ otp: String) -> Bool {
        let t = otp.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count == 6 && t.allSatisfy(\.isNumber)
    }
}

enum PasswordValidator {
    static func isValid(_ password: String) -> Bool {
        password.count >= 8
    }
}

// MARK: - VM

final class ForgetPasswordVM: BaseViewModel {

    var onLoginSuccess: ((String) -> Void)?

    private let forgotUseCase: ForgotPasswordUseCase
    private let resetUseCase: ResetPasswordUseCase

    @Published var email: String = ""
    @Published var otp: String = ""
    @Published var newPassword: String = ""

    @Published private(set) var step: ForgetPasswordStep = .enterEmail
    @Published private(set) var viewState: ForgetPasswordViewState = .init(
        showOtpSection: false,
        showPasswordSection: false,
        emailLocked: false,
        primaryTitle: "Send OTP",
        primaryEnabled: false,
        showEmailStatusIcon: false,
        showOtpHelper: false,
        showOtpCheckIcon: false,
        showPasswordHelper: true
    )

    init(forgotUseCase: ForgotPasswordUseCase, resetUseCase: ResetPasswordUseCase) {
        self.forgotUseCase = forgotUseCase
        self.resetUseCase = resetUseCase
        super.init()
        bindInputs()
        recomputeViewState()
    }

    func isValidEmail(_ email: String) -> Bool {
        EmailValidator.isValid(email)
    }

    func handlePrimaryTapped() {
        switch step {
        case .enterEmail:
            sendOtp()

        case .enterOtp:
            break

        case .enterNewPassword:
            resetPassword()

        case .loggedIn:
            break
        }
    }

    private func sendOtp() {
        let currentEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard EmailValidator.isValid(currentEmail) else {
            showError("Please enter a valid email address.")
            return
        }

        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] done in
                guard let self else { return }
                self.forgotUseCase.execute(email: currentEmail, completion: done)
            },
            errorMapper: { [weak self] error in
                self?.mapAuthError(error) ?? "Something went wrong. Please try again."
            },
            onSuccess: { [weak self] response in
                guard let self else { return }
                self.showSuccess(response.message ?? "Reset code sent.")
                self.step = .enterOtp(emailLocked: true)
                self.recomputeViewState()
            }
        )
    }

    private func resetPassword() {
        let currentEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentOtp = otp.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentPass = newPassword

        guard EmailValidator.isValid(currentEmail) else {
            showError("Please enter a valid email address.")
            return
        }
        guard OTPValidator.isValid(currentOtp) else {
            showError("Please enter a valid 6-digit OTP.")
            return
        }
        guard PasswordValidator.isValid(currentPass) else {
            showError("Must be at least 8 characters.")
            return
        }

        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] done in
                guard let self else { return }
                self.resetUseCase.execute(
                    email: currentEmail,
                    otp: currentOtp,
                    newPassword: currentPass,
                    completion: done
                )
            },
            errorMapper: { [weak self] err in
                self?.decodeServerMessage("\(err)") ?? "Something went wrong."
            },
            onSuccess: { [weak self] session in
                guard let self else { return }

                AppStorage.shared.saveLogin(
                    accessToken: session.data.accessToken,
                    userId: session.data.user.id,
                    refreshToken: session.data.refreshToken
                )

                self.showSuccess("Password updated. Logged in!")
                self.step = .loggedIn
                self.recomputeViewState()
                self.onLoginSuccess?(session.data.accessToken)
            }
        )
    }

    private func bindInputs() {
        Publishers.CombineLatest3($email, $otp, $newPassword)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _, _ in
                guard let self else { return }
                self.advanceFlowIfNeeded()
                self.recomputeViewState()
            }
            .store(in: &cancellables)

        $isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.recomputeViewState()
            }
            .store(in: &cancellables)
    }

    private func advanceFlowIfNeeded() {
        if case .enterOtp(let locked) = step, OTPValidator.isValid(otp) {
            step = .enterNewPassword(emailLocked: locked)
        }
    }

    private func recomputeViewState() {
        let emailValid = EmailValidator.isValid(email)
        let otpValid = OTPValidator.isValid(otp)
        let passValid = PasswordValidator.isValid(newPassword)

        let showOtp: Bool
        let showPass: Bool
        let emailLocked: Bool

        switch step {
        case .enterEmail:
            showOtp = false
            showPass = false
            emailLocked = false

        case .enterOtp(let locked):
            showOtp = true
            showPass = false
            emailLocked = locked

        case .enterNewPassword(let locked):
            showOtp = true
            showPass = true
            emailLocked = locked

        case .loggedIn:
            showOtp = true
            showPass = true
            emailLocked = true
        }

        let primaryTitle: String = {
            switch step {
            case .enterEmail: return "Send OTP"
            case .enterOtp: return "Send OTP"
            case .enterNewPassword: return "Log In"
            case .loggedIn: return "Log In"
            }
        }()

        let primaryEnabled: Bool = {
            if isLoading { return false }
            switch step {
            case .enterEmail:
                return emailValid
            case .enterOtp:
                return false
            case .enterNewPassword:
                return emailValid && otpValid && passValid
            case .loggedIn:
                return false
            }
        }()

        let showEmailStatusIcon = (step != .enterEmail)

        let showOtpHelper: Bool = {
            guard showOtp else { return false }
            if otp.isEmpty { return false }
            return !otpValid
        }()

        let showOtpCheckIcon: Bool = {
            guard showOtp else { return false }
            return otpValid
        }()

        viewState = .init(
            showOtpSection: showOtp,
            showPasswordSection: showPass,
            emailLocked: emailLocked,
            primaryTitle: primaryTitle,
            primaryEnabled: primaryEnabled,
            showEmailStatusIcon: showEmailStatusIcon,
            showOtpHelper: showOtpHelper,
            showOtpCheckIcon: showOtpCheckIcon,
            showPasswordHelper: true
        )
    }

    private func mapAuthError(_ error: AuthError) -> String {
        switch error {
        case .network(let message):
            return message
        case .server(let raw):
            return decodeServerMessage(raw)
        case .decoding:
            return "Unexpected response from server."
        case .invalidCredentials:
            return "Invalid credentials."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
