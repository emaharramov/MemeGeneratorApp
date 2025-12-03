//
//  CreateCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol CreateRouting: AnyObject {

    func makeAIMeme() -> UIViewController
    func makeAIWithTemplate() -> UIViewController
    func makeCustomMeme() -> UIViewController

    func showPremium()
    func showAuth()
}

final class CreateCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController
    private let factory: CreateFactory

    init(navigation: UINavigationController, factory: CreateFactory) {
        self.navigation = navigation
        self.factory = factory
    }

    func start() {
        let vc = factory.makeCreate(router: self)
        navigation.setViewControllers([vc], animated: false)
    }
}

// MARK: - CreateRouting

extension CreateCoordinator: CreateRouting {

    // MARK: Child VC factory-ləri (VC factory-dən gəlir)

    func makeAIMeme() -> UIViewController {
        factory.makeAIMeme()
    }

    func makeAIWithTemplate() -> UIViewController {
        factory.makeAIWithTemplate()
    }

    func makeCustomMeme() -> UIViewController {
        factory.makeCustomMeme()
    }

    // MARK: Navigation aksiyaları

    func showPremium() {
        let vc = factory.makePremium()
        navigation.pushViewController(vc, animated: true)
    }

    func showAuth() {
        let vc = factory.makeAuth()
        navigation.present(vc, animated: true)
    }
}
