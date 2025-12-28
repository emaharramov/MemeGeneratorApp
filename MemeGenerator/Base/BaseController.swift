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

    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()

    var usesBaseLoadingOverlay: Bool { true }

    private var loadingMessage: String? {
        didSet { loadingHelper.updateMessage(loadingMessage) }
    }

    private lazy var loadingHelper = LoadingOverlayHelper()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func configureUI() {}
    func configureConstraints() {}
    func bindViewModel() {}

    private func bindViewModelBase() {

        viewModel.shouldShowAd = { [weak self] onAdDismissed in
            guard let self = self else {
                onAdDismissed()
                return
            }

            AdMobManager.shared.showInterstitialAd(from: self) {
                onAdDismissed()
            }
        }

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
                guard let self else { return }
                if isLoading {
                    self.loadingHelper.show(on: self.view, message: self.loadingMessage)
                } else {
                    self.loadingHelper.hide()
                }
            }
            .store(in: &cancellables)
    }

    func setLoadingMessage(_ text: String?) {
        loadingMessage = text
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
}
