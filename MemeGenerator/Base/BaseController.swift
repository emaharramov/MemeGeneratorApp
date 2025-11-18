//
//  BaseController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

/// Generic base controller that standardizes lifecycle hooks for UI setup and bindings.
class BaseController<ViewModel>: UIViewController {

    // MARK: - Properties

    let viewModel: ViewModel

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        bindViewModel()
        applyDefaultBackground()
    }

    // MARK: - Template Methods

    /// Override to add subviews and static UI configuration.
    func configureUI() {}

    /// Override to add layout constraints.
    func configureConstraints() {}

    /// Override to bind the view model to the UI.
    func bindViewModel() {}

    // MARK: - Helpers

    private func isTabBarRoot() -> Bool {
        navigationController?.viewControllers.first === self && tabBarController != nil
    }

    private func applyDefaultBackground() {
        // Prefer system colors for consistency with light/dark mode
        if isTabBarRoot() {
            view.backgroundColor = UIColor.systemGroupedBackground
        } else {
            view.backgroundColor = UIColor.systemBackground
        }
    }
}
