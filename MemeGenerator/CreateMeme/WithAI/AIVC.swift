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

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

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
        view.backgroundColor = .mgBackground
        configureNavigation(title: "AI Meme")
    }

    override func configureUI() {
        super.configureUI()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        generateButton.applyFilledStyle(
            title: "Generate Meme",
            systemImageName: "sparkles",
            baseBackgroundColor: .mgAccent,
            baseForegroundColor: .mgTextSecondary
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
            action: #selector(handleGenerateTapped),
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

        // ViewState
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.handle(state: state)
            }
            .store(in: &cancellables)

        // Loading + button state + "Cooking..." tostu
        viewModel.$isLoading
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self else { return }

                self.generateButton.isEnabled = !isLoading
                self.generateButton.alpha = isLoading ? 0.6 : 1.0

                if isLoading {
                    self.showToast(
                        message: "Cooking your meme in the AI kitchen... 🔥",
                        type: .info
                    )
                    self.resultView.image = nil
                }
            }
            .store(in: &cancellables)
    }

    private func styleCard(_ view: UIView) {
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
    }

    private func handle(state: AIVM.ViewState) {
        switch state {
        case .idle:
            break

        case .memeLoaded(let urlString):
            MemeService.shared.loadImage(url: urlString) { [weak self] image in
                guard let self else { return }
                DispatchQueue.main.async {
                    guard let image else {
                        self.showToast(
                            message: "Failed to load meme image. Please try again.",
                            type: .error
                        )
                        return
                    }
                    self.resultView.image = image
                    self.shareCard.isHidden = false
                }
            }

        case .error(let message):
            print("AI error:", message)
        }
    }

    @objc private func handleGenerateTapped() {
        view.endEditing(true)
        viewModel.generateMeme(prompt: promptView.text)
    }

    private func retryGenerate() {
        handleGenerateTapped()
    }
    
    private func resetForNewMeme() {
        view.endEditing(true)
        promptView.text = ""
        resultView.image = nil
        shareCard.isHidden = true
        let topOffset = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
        scrollView.setContentOffset(topOffset, animated: true)
    }
    
    private func saveImageToPhotos() {
        guard let image = resultView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos")
    }

    private func shareMeme() {
        guard let image = resultView.image else { return }
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}
