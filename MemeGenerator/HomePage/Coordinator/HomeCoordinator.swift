//
//  HomeCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

final class HomeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController
    private let factory: HomeFactory

    init(navigation: UINavigationController, factory: HomeFactory) {
        self.navigation = navigation
        self.factory = factory
    }

    func start() {
        let vc = factory.makeHome()
        navigation.setViewControllers([vc], animated: false)
    }
}
