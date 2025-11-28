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
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray3
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false

        // Artıq blur və böyük corner radius istəmirik
        tabBar.layer.cornerRadius = 0
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowOpacity = 0
        tabBar.layer.shadowRadius = 0

        // Yalnız yuxarı tərəfdə nazik xətt (divider)
        let topLine = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: tabBar.bounds.width,
            height: 0.5
        ))
        topLine.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.7)
        topLine.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        tabBar.addSubview(topLine)
    }

    // MARK: - Tabs
    private func configureTabs() {
        let home = UINavigationController(rootViewController: HomeController(viewModel: HomeViewModel()))
        home.tabBarItem = UITabBarItem(title: "Home",
                                       image: UIImage(systemName: "house"),
                                       selectedImage: UIImage(systemName: "house.fill"))

        // Ortadakı boş container – create üçün
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

    private func setupMiddleButton() {
        // Mavi dairə
        middleButton.backgroundColor = .systemBlue
        middleButton.tintColor = .white

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        middleButton.setImage(UIImage(systemName: "plus", withConfiguration: config),
                              for: .normal)

        middleButton.layer.cornerRadius = 30
        middleButton.layer.masksToBounds = false

        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.22
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        middleButton.layer.shadowRadius = 10

        view.addSubview(middleButton)
        middleButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            middleButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            // Bir az aşağı — tabbarla overlap etsin
            middleButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 4),
            middleButton.widthAnchor.constraint(equalToConstant: 60),
            middleButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        middleButton.addTarget(self, action: #selector(openCreate), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func openCreate() {
        // Kiçik tap animasiyası
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.middleButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.12) {
                    self.middleButton.transform = .identity
                }
            }
        )

        // Create stack-i reset eləyək
        createNav.setViewControllers([CreateViewController()], animated: false)

        // Orta tab-a keç
        selectedIndex = 1

        // View controller-ları yenilə ki, ortada createNav olsun
        if let vcs = viewControllers, vcs.count == 3 {
            setViewControllers([vcs[0], createNav, vcs[2]], animated: false)
        }
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
