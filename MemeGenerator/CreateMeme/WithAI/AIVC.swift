//
//  AIVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit
import SnapKit

final class AIVC: BaseController<AIVM> {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private lazy var promptView = MemePromptView(
        title: "AI Meme",
        subtitle: "Type a fun idea and let AI generate the meme image.",
        fieldTitle: nil,
        placeholder: "e.g., A cat wearing sunglasses DJing at a party"
    )

    private let generateButton = UIButton(type: .system)
    private let resultView = MemeResultView(
        placeholderText: "Your AI meme will appear here"
    )
    private let shareActionsView = MemeShareActionsView()

    // MARK: - State

    private var generatedImage: UIImage?

    // MARK: - Init

    override init(viewModel: AIVM) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupBindings()
    }

    // MARK: - Setup

    private func setupUI() {
        // Scroll + stack
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

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

        // Generate button – FromTemplate-dəki stil
        configureGenerateButton()

        // Stack sırası: prompt, button, result, share actions
        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(generateButton)
        stackView.addArrangedSubview(resultView)
        stackView.addArrangedSubview(shareActionsView)

        generateButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        resultView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(240)
        }

        // Action-lar
        generateButton.addTarget(self,
                                 action: #selector(handleGenerateTapped),
                                 for: .touchUpInside)

        shareActionsView.onSave = { [weak self] in
            self?.saveImageToPhotos()
        }
        shareActionsView.onShare = { [weak self] in
            self?.shareMeme()
        }
        shareActionsView.onTryAgain = { [weak self] in
            self?.retryGenerate()
        }
    }

    private func configureGenerateButton() {
        generateButton.applyFilledStyle(
            title: "Generate Meme",
            systemImageName: "sparkles"
        )
    }

    private func setupBindings() {
        viewModel.onMemeGenerated = { [weak self] image in
            guard let self else { return }
            self.generatedImage = image
            self.resultView.image = image
        }

        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.showToast(message: "Preparing meme...")
            } else {
                self.showToast(message: "Meme is ready")
            }
        }

        viewModel.onError = { [weak self] message in
            self?.showToast(message: message)
        }
    }

    // MARK: - Actions

    @objc private func handleGenerateTapped() {
        let prompt = promptView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            showToast(message: "Please enter an idea")
            return
        }
//        viewModel.generateMeme(prompt: prompt)
    }

    private func retryGenerate() {
        handleGenerateTapped()
    }

    private func saveImageToPhotos() {
        guard let image = generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos")
    }

    private func shareMeme() {
        guard let image = generatedImage else { return }
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}

