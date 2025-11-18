//
//  AppCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

/// Coordinates the app's root navigation flows using a single window.
final class AppCoordinator {

    // MARK: - Properties

    private let window: UIWindow

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public API

    func start() {
        decideInitialFlow()
    }

    // MARK: - Flow

    private func decideInitialFlow() {
        if !AppStorage.shared.hasSeenOnboarding {
            showOnboarding()
            return
        }

        if AppStorage.shared.isLoggedIn {
            showTabbar()
        } else {
            showAuth()
        }
    }

    private func showOnboarding() {
        let vm = OnBoardingViewModel()
        let vc = OnboardingController(viewModel: vm)
        vm.onFinish = { [weak self] in
            AppStorage.shared.hasSeenOnboarding = true
            self?.showAuth()
        }
        setRoot(vc)
    }

    private func showAuth() {
        let vm = AuthViewModel()
        let vc = AuthController(viewModel: vm, mode: .login)
        vm.onLoginSuccess = { [weak self] token in
            AppStorage.shared.token = token
            self?.showTabbar()
        }
        vm.onRegisterSuccess = { [weak self] token in
            AppStorage.shared.token = token
            self?.showTabbar()
        }
        setRoot(vc)
    }

    private func showTabbar() {
        let vc = TabbarController()
        setRoot(vc)
    }

    // MARK: - Root Handling

    private func setRoot(_ vc: UIViewController, animated: Bool = true) {
        window.rootViewController = vc
        window.makeKeyAndVisible()
        guard animated else { return }
        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

    /// Convenience for flows like logout where you might want to reset without animation.
    func resetToRoot(_ vc: UIViewController) {
        setRoot(vc, animated: false)
    }
}
