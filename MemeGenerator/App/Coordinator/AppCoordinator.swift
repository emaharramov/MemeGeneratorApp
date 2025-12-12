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

    private lazy var networkManager = NetworkManager()

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
            showAuthFlow()
        }
    }

    private func showOnboarding() {
        let vm = OnBoardingViewModel()
        let vc = OnboardingController(viewModel: vm)

        vm.onFinish = { [weak self] in
            guard let self else { return }
            AppStorage.shared.hasSeenOnboarding = true
            self.showAuthFlow()
        }

        setRoot(vc)
    }

    private func showAuthFlow() {
        let authFactory = DefaultAuthFactory(networkManager: networkManager)
        let authCoordinator = AuthCoordinator(factory: authFactory)
        add(authCoordinator)

        authCoordinator.onFinish = { [weak self, weak authCoordinator] token in
            guard let self, let authCoordinator else { return }
            self.remove(authCoordinator)

            AppStorage.shared.accessToken = token
            AppStorage.shared.isLoggedIn = true

            self.showMainTabbar()
        }

        authCoordinator.start()
        setRoot(authCoordinator.rootViewController)
    }

    private func showMainTabbar() {
        let mainCoordinator = MainTabbarCoordinator()
        add(mainCoordinator)

        mainCoordinator.onLogout = { [weak self, weak mainCoordinator] in
            guard let self, let mainCoordinator else { return }
            self.remove(mainCoordinator)

            AppStorage.shared.isLoggedIn = false
            AppStorage.shared.accessToken = nil

            self.showAuthFlow()
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
}
