//
//  AuthFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import UIKit

protocol AuthFactory {
    func makeAuth(mode: AuthMode, router: AuthRouting) -> UIViewController
    func makeForgotPassword(router: AuthRouting) -> UIViewController
    func makeEmailVerification(email: String, router: AuthRouting) -> UIViewController
}

final class DefaultAuthFactory: AuthFactory {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func makeAuth(mode: AuthMode, router: AuthRouting) -> UIViewController {
        let authRepository = AuthRepositoryImpl(networkManager: networkManager)

        let loginUseCase = LoginUseCaseImpl(repository: authRepository)
        let registerUseCase = RegisterUseCaseImpl(repository: authRepository)

        let vm = AuthViewModel(loginUseCase: loginUseCase, registerUseCase: registerUseCase)
        let vc = AuthController(viewModel: vm, mode: mode, router: router)

        vm.onLoginSuccess = { token in
            router.authDidFinish(accessToken: token)
        }

        vm.onRegisterRequiresVerification = { email in
            router.showEmailVerification(email: email)
        }

        return vc
    }

    func makeForgotPassword(router: AuthRouting) -> UIViewController {
        let authRepository = AuthRepositoryImpl(networkManager: networkManager)

        let forgotUseCase = ForgotPasswordUseCaseImpl(repository: authRepository)
        let resetUseCase = ResetPasswordUseCaseImpl(repository: authRepository)

        let vm = ForgetPasswordVM(forgotUseCase: forgotUseCase, resetUseCase: resetUseCase)

        vm.onLoginSuccess = { token in
            router.authDidFinish(accessToken: token)
        }

        let vc = ForgetPasswordController(viewModel: vm)
        return vc
    }

    func makeEmailVerification(email: String, router: AuthRouting) -> UIViewController {
        let authRepository = AuthRepositoryImpl(networkManager: networkManager)

        let verifyUseCase = VerifyEmailUseCaseImpl(repository: authRepository)
        let resendUseCase = ResendEmailCodeUseCaseImpl(repository: authRepository)

        let vm = VerifyEmailViewModel(
            email: email,
            verifyUseCase: verifyUseCase,
            resendUseCase: resendUseCase
        )

        vm.onVerified = { token in
            router.authDidFinish(accessToken: token)
        }

        let vc = VerifyEmailController(viewModel: vm)
        return vc
    }
}
