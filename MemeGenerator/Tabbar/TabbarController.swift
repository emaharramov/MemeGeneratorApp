//
//  TabbarController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class TabbarController: UITabBarController, UITabBarControllerDelegate {

    private let homeNav: UINavigationController
    private let createNav: UINavigationController
    private let profileNav: UINavigationController

    private let middleButton = UIButton()

    // MARK: - Init

    init(homeNav: UINavigationController,
         createNav: UINavigationController,
         profileNav: UINavigationController) {

        self.homeNav = homeNav
        self.createNav = createNav
        self.profileNav = profileNav
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

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
        // Home item
        homeNav.tabBarItem = UITabBarItem(
            title: "Memes",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Create – ortadakı tab əslində placeholder kimi işləyir
        createNav.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        createNav.tabBarItem.isEnabled = false

        // Profile item
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [homeNav, createNav, profileNav]
    }

    // MARK: - Middle Button

    private func setupMiddleButton() {
        middleButton.backgroundColor = UIColor.systemBlue
        middleButton.tintColor = .white
        middleButton.layer.cornerRadius = 32
        middleButton.setImage(UIImage(systemName: "plus"), for: .normal)

        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.25
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        middleButton.layer.shadowRadius = 8

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
        UIView.animate(withDuration: 0.12, animations: {
            self.middleButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.middleButton.transform = .identity
            }
        })

        selectedIndex = 1
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
