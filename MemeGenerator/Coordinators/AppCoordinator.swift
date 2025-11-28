//
//  AppCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        decideInitialFlow()
    }

    private func decideInitialFlow() {
        if !AppStorage.shared.hasSeenOnboarding {
            showOnboarding()
            return
        }

        if AppStorage.shared.isLoggedIn {
            showMainTabbar()
        } else {
            showAuth()
        }
    }

    private func showOnboarding() {
        let vm = OnBoardingViewModel()
        let vc = OnboardingController(viewModel: vm)

        vm.onFinish = { [weak self] in
            guard let self else { return }
            AppStorage.shared.hasSeenOnboarding = true
            self.showAuth()
        }

        setRoot(vc)
    }

    private func showAuth() {
        let networkManager = NetworkManager()
        let authRepository = AuthRepositoryImpl(networkManager: networkManager)

        let loginUseCase = LoginUseCaseImpl(repository: authRepository)
        let registerUseCase = RegisterUseCaseImpl(repository: authRepository)
        let vm = AuthViewModel(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase
        )
        let vc = AuthController(viewModel: vm, mode: .login)
        vm.onLoginSuccess = { [weak self] token in
            guard let self else { return }
            AppStorage.shared.token = token
            AppStorage.shared.isLoggedIn = true
            self.showMainTabbar()
        }

        vm.onRegisterSuccess = { [weak self] token in
            guard let self else { return }
            AppStorage.shared.token = token
            AppStorage.shared.isLoggedIn = true
            self.showMainTabbar()
        }

        setRoot(vc)
    }

    private func showMainTabbar() {
        let mainCoordinator = MainTabbarCoordinator()
        add(mainCoordinator)

        mainCoordinator.onLogout = { [weak self, weak mainCoordinator] in
            guard let self, let mainCoordinator else { return }
            self.remove(mainCoordinator)
            AppStorage.shared.isLoggedIn = false
            AppStorage.shared.token = nil
            self.showAuth()
        }

        mainCoordinator.start()
        setRoot(mainCoordinator.rootViewController)
    }

    private func setRoot(_ vc: UIViewController, animated: Bool = true) {
        window.rootViewController = vc
        window.makeKeyAndVisible()

        guard animated else { return }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }

    func resetToRoot(_ vc: UIViewController) {
        setRoot(vc, animated: false)
    }
}
