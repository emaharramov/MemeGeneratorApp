//
//  Coordinator.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func add(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func remove(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
