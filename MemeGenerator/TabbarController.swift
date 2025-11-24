//
//  TabbarController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate {

    private let middleButton = UIButton()

    // Create üçün ayrıca navigation
    private lazy var createNav = UINavigationController(rootViewController: CreateViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        configureAppearance()
        configureTabs()
        setupMiddleButton()
    }

    // MARK: - Tab Bar UI
    private func configureAppearance() {
        tabBar.tintColor = UIColor.black
        tabBar.unselectedItemTintColor = .systemGray3

        tabBar.layer.cornerRadius = 26
        tabBar.layer.masksToBounds = false
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
        blurView.frame = tabBar.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.insertSubview(blurView, at: 0)

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.15
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowRadius = 10
    }


    // MARK: - Tabs
    private func configureTabs() {

        let home = UINavigationController(rootViewController: HomeController(viewModel: HomeViewModel()))
        home.tabBarItem = UITabBarItem(title: "Home",
                                       image: UIImage(systemName: "house"),
                                       selectedImage: UIImage(systemName: "house.fill"))

        let createContainer = UIViewController()
        createContainer.tabBarItem = UITabBarItem(title: nil,
                                                  image: nil,
                                                  selectedImage: nil)
        createContainer.tabBarItem.isEnabled = false

        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: "Profile",
                                          image: UIImage(systemName: "person"),
                                          selectedImage: UIImage(systemName: "person.fill"))

        viewControllers = [home, createContainer, profile]
    }

    // MARK: - Middle Button
    private func setupMiddleButton() {
        middleButton.backgroundColor = UIColor(red: 1, green: 0.97, blue: 0.7, alpha: 1)
        middleButton.tintColor = .black
        middleButton.layer.cornerRadius = 32
        middleButton.setImage(UIImage(systemName: "sparkles"), for: .normal)

        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.25
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        middleButton.layer.shadowRadius = 8

        middleButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

        view.addSubview(middleButton)
        middleButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            middleButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            middleButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            middleButton.widthAnchor.constraint(equalToConstant: 64),
            middleButton.heightAnchor.constraint(equalToConstant: 64)
        ])

        middleButton.addTarget(self, action: #selector(openCreate), for: .touchUpInside)
    }

    @objc private func openCreate() {

        // Animation — fun effect
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.middleButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.12) {
                    self.middleButton.transform = .identity
                }
            }
        )

        // Create stack reset
        createNav.setViewControllers([CreateViewController()], animated: false)

        // Create tab-a keçirik (index 1)
        selectedIndex = 1

        // VC-nin yerinə bizim createNav göstərilsin
        setViewControllers([viewControllers![0], createNav, viewControllers![2]], animated: false)
    }


    // MARK: - Tab Animation
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {

        guard
            let itemView = viewController.tabBarItem.value(forKey: "view") as? UIView
        else { return }

        UIView.animate(withDuration: 0.12, animations: {
            itemView.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                itemView.transform = .identity
            }
        }
    }
}
