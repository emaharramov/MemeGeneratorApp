//
//  BaseController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Combine

class BaseController<ViewModel: BaseViewModel>: UIViewController {
    var viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        bindViewModel()
        applyDefaultBackground()
        bindViewModelBase()
    }

    func configureUI() {}
    func configureConstraints() {}
    func bindViewModel() {}

    private func bindViewModelBase() {
        viewModel.$errorMessage
            .sink { [weak self] message in
                guard let message else { return }
                self?.showToast(message: message, type: .error)
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .sink { [weak self] message in
                guard let message else { return }
                self?.showToast(message: message, type: .success)
            }
            .store(in: &cancellables)
    }
    
    private func isTabBarRoot() -> Bool {
        navigationController?.viewControllers.first === self && tabBarController != nil
    }

    private func applyDefaultBackground() {
        view.backgroundColor = isTabBarRoot()
            ? UIColor.systemGroupedBackground
            : UIColor.systemBackground
    }
}
