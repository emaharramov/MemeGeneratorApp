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

    var usesBaseLoadingOverlay: Bool { true }

    private let loadingMessages: [String] = [
        "Cooking your meme in the AI kitchen... 🔥",
        "Adding extra sarcasm to your meme... 😏",
        "Asking the internet if this meme is legal... 🌐",
        "Teaching AI what 'relatable' means... 🤖",
        "Optimizing pixels for maximum fun... 🎯",
        "Googling: 'why is this so funny?' 😂",
        "Ensuring your meme passes the vibe check... ✅"
    ]

    private var currentMessageIndex: Int = 0
    private var loadingMessageTimer: Timer?

    private let loadingTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    private let loadingSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = true

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "sparkles"))
        icon.tintColor = .white
        icon.preferredSymbolConfiguration = .init(pointSize: 26, weight: .semibold)

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.tintColor = .white

        loadingTitleLabel.text = "Cooking your meme... 🔥"
        loadingSubtitleLabel.text = "Tap for a new fun status 😄"

        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(loadingTitleLabel)
        stack.addArrangedSubview(loadingSubtitleLabel)
        stack.addArrangedSubview(indicator)

        blur.contentView.addSubview(stack)
        overlay.addSubview(blur)

        blur.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(overlay.safeAreaLayoutGuide).offset(32)
            make.trailing.lessThanOrEqualTo(overlay.safeAreaLayoutGuide).inset(32)
        }

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18))
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLoadingOverlayTap))
        overlay.addGestureRecognizer(tap)

        return overlay
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

        guard usesBaseLoadingOverlay else { return }

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
            startLoadingMessages()
            animateLoadingOverlay(show: true)
            return
        }

        view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.layoutIfNeeded()
        startLoadingMessages()
        animateLoadingOverlay(show: true)
    }

    private func hideLoadingOverlay() {
        guard loadingOverlay.superview != nil else { return }
        stopLoadingMessages()
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

    private func startLoadingMessages() {
        currentMessageIndex = 0
        updateLoadingMessage()

        loadingMessageTimer?.invalidate()
        loadingMessageTimer = Timer.scheduledTimer(
            timeInterval: 1.5,
            target: self,
            selector: #selector(handleLoadingMessageTick),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopLoadingMessages() {
        loadingMessageTimer?.invalidate()
        loadingMessageTimer = nil
    }

    private func updateLoadingMessage() {
        guard !loadingMessages.isEmpty else { return }
        let message = loadingMessages[currentMessageIndex]
        loadingTitleLabel.text = message
    }

    @objc private func handleLoadingMessageTick() {
        guard !loadingMessages.isEmpty else { return }
        currentMessageIndex = (currentMessageIndex + 1) % loadingMessages.count
        UIView.transition(
            with: loadingTitleLabel,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.updateLoadingMessage()
            },
            completion: nil
        )
    }

    @objc private func handleLoadingOverlayTap() {
        handleLoadingMessageTick()
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
