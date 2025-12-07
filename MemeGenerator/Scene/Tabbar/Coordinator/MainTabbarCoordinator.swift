//
//  MainTabbarCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

// MainTabbarCoordinator.swift

import UIKit

final class MainTabbarCoordinator: Coordinator {

    // MARK: - Coordinator
    var childCoordinators: [Coordinator] = []

    // MARK: - Callbacks
    var onLogout: (() -> Void)?

    // MARK: - Navigation controllers (hər tab üçün)
    private let homeNavigation: UINavigationController
    private let createNavigation: UINavigationController
    private let profileNavigation: UINavigationController

    // MARK: - Factories
    private let homeFactory: HomeFactory
    private let createFactory: CreateFactory
    private let profileFactory: ProfileFactory

    // Tabbar root VC
    let rootViewController: UITabBarController

    // MARK: - Init
    init(
        homeNavigation: UINavigationController = UINavigationController(),
        createNavigation: UINavigationController = UINavigationController(),
        profileNavigation: UINavigationController = UINavigationController(),
        homeFactory: HomeFactory = HomeFeedFactory(),
        createFactory: CreateFactory = DefaultCreateFactory(),
        profileFactory: ProfileFactory = DefaultProfileFactory()
    ) {
        self.homeNavigation = homeNavigation
        self.createNavigation = createNavigation
        self.profileNavigation = profileNavigation
        self.homeFactory = homeFactory
        self.createFactory = createFactory
        self.profileFactory = profileFactory

        let tabbar = TabbarController(
            homeNav: homeNavigation,
            createNav: createNavigation,
            profileNav: profileNavigation
        )
        self.rootViewController = tabbar
    }

    // MARK: - Start
    func start() {
        let homeCoordinator = FeedCoordinator(
            navigation: homeNavigation,
            factory: homeFactory
        )
        add(homeCoordinator)
        homeCoordinator.start()

        let createCoordinator = CreateCoordinator(
            navigation: createNavigation,
            factory: createFactory
        )
        add(createCoordinator)
        createCoordinator.start()

        let profileCoordinator = ProfileCoordinator(
            navigation: profileNavigation,
            factory: profileFactory
        )
        add(profileCoordinator)

        profileCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }

        profileCoordinator.start()
    }
}
