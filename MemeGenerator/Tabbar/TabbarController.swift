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

    private let middleButton = UIButton(type: .system)
    private let middleTitleLabel = UILabel()

    // Status bar rəngi üçün (selected VC-dən götür)
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }

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
        setupMiddleTitle()
    }

    // MARK: - Tab Bar UI

    private func configureAppearance() {
        view.backgroundColor = .mgBackground

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .mgBackground
        appearance.shadowColor = .clear
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .mgAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.mgAccent,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.isTranslucent = false
        tabBar.tintColor = .mgAccent
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)

        tabBar.layer.cornerRadius = 26
        tabBar.layer.masksToBounds = false
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.35
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowRadius = 16
    }

    // MARK: - Tabs

    private func configureTabs() {
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        createNav.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        createNav.tabBarItem.isEnabled = false

        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [homeNav, createNav, profileNav]
    }

    // MARK: - Middle Button

    private func setupMiddleButton() {
        middleButton.backgroundColor = .mgAccent
        middleButton.tintColor = .black
        middleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        middleButton.layer.cornerRadius = 32

        // Glow effekti
        middleButton.layer.shadowColor = UIColor.mgAccent.cgColor
        middleButton.layer.shadowOpacity = 0.8
        middleButton.layer.shadowOffset = .zero
        middleButton.layer.shadowRadius = 18

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

    private func setupMiddleTitle() {
        middleTitleLabel.text = "Create"
        middleTitleLabel.textColor = .mgAccent
        middleTitleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        middleTitleLabel.textAlignment = .center

        view.addSubview(middleTitleLabel)
        middleTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            middleTitleLabel.topAnchor.constraint(equalTo: middleButton.bottomAnchor, constant: 6),
            middleTitleLabel.centerXAnchor.constraint(equalTo: middleButton.centerXAnchor)
        ])
    }

    @objc private func openCreate() {
        // Kiçik tap effekt
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
            let itemView = viewController.tabBarItem.value(forKey: "view") as? UIView,
            viewController !== createNav
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
