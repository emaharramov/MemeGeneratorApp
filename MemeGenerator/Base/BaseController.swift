//
//  BaseController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Combine

/// Base UIViewController supporting MVVM and UI event binding.
class BaseController<ViewModel: BaseViewModel>: UIViewController {

    // MARK: - Properties
    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        bindViewModel()
        applyDefaultBackground()
        setupLogoutButtonIfNeeded()
        bindViewModelBase()
    }

    // MARK: - UI / Layout Hooks
    func configureUI() {}
    func configureConstraints() {}
    func bindViewModel() {}

    // MARK: - Bind ViewModel
    private func bindViewModelBase() {
        // Error Toast
        viewModel.$errorMessage
            .sink { [weak self] message in
                guard let message else { return }
                self?.showToast(message: message, type: .error)
            }
            .store(in: &cancellables)

        // Success Toast
        viewModel.$successMessage
            .sink { [weak self] message in
                guard let message else { return }
                self?.showToast(message: message, type: .success)
            }
            .store(in: &cancellables)
    }

    // MARK: - Logout Button
    private func setupLogoutButtonIfNeeded() {
        guard shouldShowLogout else { return }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
    }

    var shouldShowLogout: Bool {
        // Do NOT show logout on Auth screens
        !(self is AuthController)
    }

    @objc private func didTapLogout() {
        LogoutService.shared.logout()
    }

    // MARK: - Helpers
    private func isTabBarRoot() -> Bool {
        navigationController?.viewControllers.first === self && tabBarController != nil
    }

    private func applyDefaultBackground() {
        view.backgroundColor = isTabBarRoot()
            ? UIColor.systemGroupedBackground
            : UIColor.systemBackground
    }
}
