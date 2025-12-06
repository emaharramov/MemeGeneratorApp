//
//  AIVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit
import SnapKit
import Combine

final class AIVC: BaseController<AIVM> {

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        v.backgroundColor = .clear
        return v
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.alignment = .fill
        return s
    }()

    private let refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = Palette.mgAccent
        return r
    }()

    private lazy var promptView: MemePromptView = {
        let view = MemePromptView(
            title: "AI Meme",
            subtitle: "Describe your meme and let AI create the perfect image.",
            fieldTitle: nil,
            placeholder: ""
        )
        view.setPlaceholderWithIcon(
            text: "Write Your Idea",
            systemImageName: "sparkles"
        )
        return view
    }()

    private let generateButton = UIButton(type: .system)

    private let resultCard = UIView()
    private let resultView = MemeResultView(
        placeholderText: "Your AI meme will appear here"
    )

    private let shareCard = UIView()
    private let shareActionsView = MemeShareActionsView()

    private var cancellables = Set<AnyCancellable>()

    override init(viewModel: AIVM) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        configureNavigation(title: "AI Meme")
    }

    override func configureUI() {
        super.configureUI()

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        generateButton.applyFilledStyle(
            title: "Generate Meme",
            systemImageName: "sparkles",
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextPrimary
        )
        generateButton.layer.cornerRadius = 20
        generateButton.clipsToBounds = false

        styleCard(resultCard)
        resultCard.addSubview(resultView)

        styleCard(shareCard)
        shareCard.addSubview(shareActionsView)
        shareCard.isHidden = true

        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(generateButton)
        stackView.addArrangedSubview(resultCard)
        stackView.addArrangedSubview(shareCard)

        generateButton.addTarget(
            self,
            action: #selector(retryGenerate),
            for: .touchUpInside
        )

        shareActionsView.onSave = { [weak self] in
            self?.saveImageToPhotos()
        }
        shareActionsView.onShare = { [weak self] in
            self?.shareMeme()
        }
        shareActionsView.onTryAgain = { [weak self] in
            self?.retryGenerate()
        }
        shareActionsView.onRegenerate = { [weak self] in
            self?.resetForNewMeme()
        }
    }

    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }

        generateButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        resultView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        shareActionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.handle(state: state)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self else { return }

                self.generateButton.isEnabled = !isLoading
                self.generateButton.alpha = isLoading ? 0.6 : 1.0

                if isLoading {
                    setLoadingMessage("Cooking your meme to perfection – this may take up to a minute ⏳")
                    self.resultView.image = nil
                }
            }
            .store(in: &cancellables)
    }

    private func handle(state: AIVM.ViewState) {
        switch state {
        case .idle:
            break
        case .memeLoaded(let image):
            resultView.image = image
            shareCard.isHidden = false
            showToast(
                message: "We hope you are smiling now 🔥",
                type: .success
            )
        case .error(let message):
            showToast(message: message, type: .error)
            shareCard.isHidden = true
        }
    }

    private func styleCard(_ view: UIView) {
        view.backgroundColor = Palette.mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
    }

    @objc private func handleRefresh() {
        resetForNewMeme()
        refreshControl.endRefreshing()
    }

    @objc private func retryGenerate() {
        view.endEditing(true)
        guard let prompt = validatePrompt(promptView.text) else { return }
        viewModel.generateMeme(prompt: prompt)
    }

    private func resetForNewMeme() {
        view.endEditing(true)
        promptView.text = ""
        resultView.image = nil
        shareCard.isHidden = true
        scrollView.scrollToTop()
    }

    private func saveImageToPhotos() {
        saveToPhotos(resultView.image)
    }

    private func shareMeme() {
        shareImage(resultView.image, from: resultView)
    }
}
