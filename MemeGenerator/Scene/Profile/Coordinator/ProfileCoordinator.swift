//
//  ProfileCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit
import RevenueCat

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

// MARK: - ProfileRouting

extension ProfileCoordinator: ProfileRouting {

    func showEditProfile() {
        let vc = factory.makeEditProfile()
        navigation.pushViewController(vc, animated: true)
    }

    func showPremium() {
        let vc = factory.makePremium()
        navigation.pushViewController(vc, animated: true)
    }

    func showSubscription() {
        let vc = factory.makeManageSubscription()
        navigation.pushViewController(vc, animated: true)
    }

    func showMyMemes() {
        let vc = factory.makeMyMemes(router: self)
        navigation.pushViewController(vc, animated: true)
    }

    func showHelp() {
        let vc = factory.makeHelp(router: self)
        navigation.pushViewController(vc, animated: true)
    }

    func performLogout() {
        guard let hostView = navigation.view else { return }

        MGAlertOverlay.show(
            on: hostView,
            title: "Log out",
            message: "Are you sure you want to log out?",
            primaryTitle: "Log out",
            secondaryTitle: "Cancel",
            emoji: "🤔",
            onPrimary: { [weak self] in
                guard let self else { return }
                AppStorage.shared.isLoggedIn = false
                AppStorage.shared.accessToken = nil
                Purchases.shared.logOut { error,err  in
                   if let error {
                       print("RevenueCat logOut error:", error)
                   }
                }
                self.onLogout?()
            }
        )
    }
}

// MARK: - MyMemesRouting

extension ProfileCoordinator: MyMemesRouting {
    func showMyMemes(mode: MyMemesMode) {
        let vc = factory.makeMyMemesGrid(mode: mode)
        navigation.pushViewController(vc, animated: true)
    }
}
