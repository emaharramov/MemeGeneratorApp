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

    /// Alt controller-lər override edib true etsə, loading overlay işə düşür
    var usesBaseLoadingOverlay: Bool { true }

    // MARK: - Loading UI (textsİz, modern)

    private let loaderContainer = UIView()
    private let loaderReplicator = CAReplicatorLayer()
    private let loaderDot = CALayer()
    private var loaderConfigured = false

    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.layer.cornerRadius = 22
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
        loaderContainer.backgroundColor = .clear

        blur.contentView.addSubview(loaderContainer)
        overlay.addSubview(blur)

        blur.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(82)
        }

        loaderContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(54)
        }

        // Kiçik inner circular background (daha meme vibe üçün)
        let innerCircle = UIView()
        innerCircle.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        innerCircle.layer.cornerRadius = 27
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.insertSubview(innerCircle, belowSubview: loaderContainer)

        innerCircle.snp.makeConstraints { make in
            make.center.equalTo(loaderContainer)
            make.width.height.equalTo(54)
        }

        return overlay
    }()

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
        setupKeyboardDismissGesture()
        bindViewModelBase()
    }

    // MARK: - To be overridden by subclasses

    func configureUI() {}
    func configureConstraints() {}
    func bindViewModel() {}

    // MARK: - Base ViewModel bindings

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

        guard usesBaseLoadingOverlay else { return }

        viewModel.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                self?.setLoadingOverlayVisible(isLoading)
            }
            .store(in: &cancellables)
    }

    // MARK: - Loading Overlay Control

    private func setLoadingOverlayVisible(_ visible: Bool) {
        if visible {
            showLoadingOverlay()
        } else {
            hideLoadingOverlay()
        }
    }

    private func showLoadingOverlay() {
        guard loadingOverlay.superview == nil else {
            startLoaderAnimation()
            animateLoadingOverlay(show: true)
            return
        }

        view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.layoutIfNeeded()
        startLoaderAnimation()
        animateLoadingOverlay(show: true)
    }

    private func hideLoadingOverlay() {
        guard loadingOverlay.superview != nil else { return }
        stopLoaderAnimation()
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

    // MARK: - Loader Animation (CAReplicatorLayer, circular dots)

    private func configureLoaderIfNeeded() {
        guard !loaderConfigured else { return }
        loaderConfigured = true

        loaderReplicator.frame = loaderContainer.bounds

        let dotSize: CGFloat = 8
        let radius = loaderContainer.bounds.width / 2 - dotSize

        loaderDot.frame = CGRect(
            x: loaderContainer.bounds.midX - dotSize / 2,
            y: loaderContainer.bounds.midY - radius - dotSize / 2,
            width: dotSize,
            height: dotSize
        )
        loaderDot.backgroundColor = UIColor.white.cgColor
        loaderDot.cornerRadius = dotSize / 2
        loaderDot.masksToBounds = true

        loaderReplicator.instanceCount = 10
        let angle = (2 * CGFloat.pi) / CGFloat(loaderReplicator.instanceCount)
        loaderReplicator.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        loaderReplicator.instanceDelay = 0.07

        loaderReplicator.addSublayer(loaderDot)
        loaderContainer.layer.addSublayer(loaderReplicator)
    }

    private func startLoaderAnimation() {
        loaderContainer.layoutIfNeeded()
        configureLoaderIfNeeded()

        loaderDot.removeAllAnimations()

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 0.3
        scaleAnim.duration = 0.6
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = .infinity
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.2
        opacityAnim.duration = 0.6
        opacityAnim.autoreverses = true
        opacityAnim.repeatCount = .infinity
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 0.6
        group.autoreverses = true
        group.repeatCount = .infinity

        loaderDot.add(group, forKey: "loader.dot.animation")
    }

    private func stopLoaderAnimation() {
        loaderDot.removeAllAnimations()
    }

    // MARK: - Navigation helpers

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

    // MARK: - Keyboard dismiss

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

    // MARK: - Background

    private func isTabBarRoot() -> Bool {
        navigationController?.viewControllers.first === self && tabBarController != nil
    }

    private func applyDefaultBackground() {
        view.backgroundColor = isTabBarRoot()
            ? UIColor.systemGroupedBackground
            : UIColor.systemBackground
    }
}
