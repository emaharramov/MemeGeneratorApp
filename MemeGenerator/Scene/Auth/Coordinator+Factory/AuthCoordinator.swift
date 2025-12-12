//
//  AuthCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import UIKit

final class AuthCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    let rootViewController: UINavigationController
    private let factory: AuthFactory

    var onFinish: ((String) -> Void)?

    init(factory: AuthFactory) {
        self.factory = factory
        self.rootViewController = UINavigationController()
    }

    func start() {
        showAuth(mode: .login)
    }

    private func showAuth(mode: AuthMode) {
        let vc = factory.makeAuth(mode: mode, router: self)
        rootViewController.setViewControllers([vc], animated: false)
    }
}

extension AuthCoordinator: AuthRouting {

    func showForgotPassword() {
        let vc = factory.makeForgotPassword(router: self)
        rootViewController.pushViewController(vc, animated: true)
    }

    func authDidFinish(accessToken: String) {
        onFinish?(accessToken)
    }
}
