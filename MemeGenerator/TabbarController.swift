//
//  TabbarController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate {

    private let middleButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
        configureTabs()
        setupMiddleButton()
    }

    // MARK: - Tab Bar Appearance
    private func configureAppearance() {
        tabBar.layer.cornerRadius = 28
        tabBar.layer.masksToBounds = true
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blurView.frame = tabBar.bounds
        blurView.isUserInteractionEnabled = false
        tabBar.insertSubview(blurView, at: 0)

        tabBar.tintColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1)
        tabBar.unselectedItemTintColor = .systemGray3

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.15
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowRadius = 12
    }

    // MARK: - VIEW CONTROLLERS
    private func configureTabs() {
        // HOME
        let homeVC = UINavigationController(rootViewController: HomeController(viewModel: BaseViewModel()))
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house"),
                                         selectedImage: UIImage(systemName: "house.fill"))
        homeVC.tabBarItem.tag = 0

        let emptyVC = UIViewController()
        let emptyItem = UITabBarItem()
        emptyItem.isEnabled = false
        emptyItem.title = nil
        emptyItem.image = nil
        emptyItem.tag = 1
        emptyVC.tabBarItem = emptyItem

        // PROFILE
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile",
                                            image: UIImage(systemName: "person"),
                                            selectedImage: UIImage(systemName: "person.fill"))
        profileVC.tabBarItem.tag = 2

        viewControllers = [homeVC, emptyVC, profileVC]
    }


    // MARK: - Middle Button Setup
    private func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 64, height: 64)
        middleButton.layer.cornerRadius = 32
        middleButton.backgroundColor = UIColor(red: 1, green: 0.97, blue: 0.7, alpha: 1)

        middleButton.setImage(UIImage(systemName: "sparkles"), for: .normal)
        middleButton.tintColor = .black

        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.25
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        middleButton.layer.shadowRadius = 6

        middleButton.addTarget(self, action: #selector(didTapMiddleButton), for: .touchUpInside)

        view.addSubview(middleButton)

        middleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            middleButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            middleButton.widthAnchor.constraint(equalToConstant: 64),
            middleButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    @objc private func didTapMiddleButton() {
        let createVC = CreateViewController()

        guard let nav = selectedViewController as? UINavigationController else { return }

        if nav.topViewController is CreateViewController {
            return
        }

        nav.pushViewController(createVC, animated: true)
    }


    // MARK: - Animation
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {

        guard let tabBarItemView = viewController.tabBarItem.value(forKey: "view") as? UIView else { return }

        UIView.animate(withDuration: 0.15,
                       animations: {
            tabBarItemView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                tabBarItemView.transform = .identity
            }
        })
    }
}
