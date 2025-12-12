//
//  CreateCoordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

final class CreateCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController
    private let factory: CreateFactory

    init(navigation: UINavigationController, factory: CreateFactory) {
        self.navigation = navigation
        self.factory = factory
    }

    func start() {
        let segments: [CreateSegmentItem] = [
            .init(title: "With AI", viewController: factory.makeAIMeme()),
            .init(title: "Template", viewController: factory.makeAIWithTemplate()),
            .init(title: "Upload", viewController: factory.makeCustomMeme())
        ]

        let vc = factory.makeCreate(segments: segments)
        navigation.setViewControllers([vc], animated: false)
    }
}
