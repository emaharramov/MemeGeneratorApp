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

        vm.onRegisterSuccess = { token in
            router.authDidFinish(accessToken: token)
        }

        return vc
    }

    func makeForgotPassword(router: AuthRouting) -> UIViewController {
        let vm = ForgetPasswordVM()
        let vc = ForgetPasswordController(viewModel: vm)
        return vc
    }
}
