//
//  TabbarController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureTabs()
    }

    // MARK: - Configuration

    private func configureAppearance() {
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .white
    }

    private func configureTabs() {
        let home = makeHome()
        viewControllers = [home]
    }

    private func makeHome() -> UINavigationController {
        let homeVC = HomeController(viewModel: BaseViewModel())
        let nav = UINavigationController(rootViewController: homeVC)
        nav.navigationBar.prefersLargeTitles = false
        nav.tabBarItem = UITabBarItem(title: "Store",
                                      image: UIImage(named: "store"),
                                      tag: 0)
        return nav
    }
}
