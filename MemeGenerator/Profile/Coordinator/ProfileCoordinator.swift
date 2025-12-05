//
//  ProfileCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController
    private let factory: ProfileFactory

    var onLogout: (() -> Void)?

    init(navigation: UINavigationController, factory: ProfileFactory) {
        self.navigation = navigation
        self.factory = factory
    }

    func start() {
        let vc = factory.makeProfile(router: self)
        navigation.setViewControllers([vc], animated: false)
    }
}


extension ProfileCoordinator: ProfileRouting {

    func showEditProfile() {
        let vc = factory.makeEditProfile()
        navigation.pushViewController(vc, animated: true)
    }

    func showPremium() {
        let vc = factory.makePremium()
        navigation.pushViewController(vc, animated: true)
    }

    func showMyMemes() {
        let vc = factory.makeMyMemes()
        navigation.pushViewController(vc, animated: true)
    }

    func showHelp() {
        let vc = factory.makeHelp(router: self)
        navigation.pushViewController(vc, animated: true)
    }

    func performLogout() {
        let alert = UIAlertController(
            title: "Log out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            AppStorage.shared.isLoggedIn = false
            AppStorage.shared.accessToken = nil
            self.onLogout?()
        }))

        navigation.present(alert, animated: true)
    }

    func forceLogout() {
        AppStorage.shared.isLoggedIn = false
        AppStorage.shared.accessToken = nil
        self.onLogout?()
    }
}
