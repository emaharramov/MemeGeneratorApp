//
//  BaseController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import Combine
import SnapKit

class BaseController<ViewModel: BaseViewModel>: UIViewController {
    var viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        view.isUserInteractionEnabled = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.layer.cornerRadius = 16
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.startAnimating()

        blur.contentView.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor)
        ])

        view.addSubview(blur)

        blur.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.greaterThanOrEqualTo(80)
        }

        blur.setContentHuggingPriority(.required, for: .horizontal)
        blur.setContentCompressionResistancePriority(.required, for: .horizontal)

        return view
    }()

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
        setupKeyboardDismissGesture()
        bindViewModelBase()
    }

    func configureUI() {}
    func configureConstraints() {}
    func bindViewModel() {}

    private func bindViewModelBase() {
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self, let message else { return }
                self.showToast(message: message, type: .error)
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self, let message else { return }
                self.showToast(message: message, type: .success)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                self?.setLoadingOverlayVisible(isLoading)
            }
            .store(in: &cancellables)
    }

    private func setLoadingOverlayVisible(_ visible: Bool) {
        if visible {
            showLoadingOverlay()
        } else {
            hideLoadingOverlay()
        }
    }

    private func showLoadingOverlay() {
        guard loadingOverlay.superview == nil else {
            animateLoadingOverlay(show: true)
            return
        }

        view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.layoutIfNeeded()
        animateLoadingOverlay(show: true)
    }

    private func hideLoadingOverlay() {
        guard loadingOverlay.superview != nil else { return }
        animateLoadingOverlay(show: false) { [weak self] in
            self?.loadingOverlay.removeFromSuperview()
        }
    }

    private func animateLoadingOverlay(show: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            self.loadingOverlay.alpha = show ? 1 : 0
        } completion: { _ in
            completion?()
        }
    }

    func configureNavigation(
        title: String,
        prefersLargeTitles: Bool = false,
        hideBackButtonTitle: Bool = true
    ) {
        self.title = title
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles

        if hideBackButtonTitle {
            let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }
    }

    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapToDismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleTapToDismissKeyboard() {
        view.endEditing(true)
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
