//
//  HomeFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol HomeFactory {
    func makeHome() -> UIViewController
}

final class DefaultHomeFactory: HomeFactory {
    func makeHome() -> UIViewController {
        let vm = HomeViewModel()
        let vc = HomeController(viewModel: vm)
        return vc
    }
}
