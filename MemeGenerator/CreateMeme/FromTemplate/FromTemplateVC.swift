//
//  FromTemplateVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class FromTemplateVC: BaseController<FromTemplateVM> {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    // Prompt – AIVC-dəki ilə eyni stil, sadəcə text fərqlidir
    private lazy var promptView: MemePromptView = {
        let view = MemePromptView(
            title: "AI + Template",
            subtitle: "Write your idea and pick a classic meme template. AI will generate the perfect meme for you.",
            fieldTitle: "",
            placeholder: ""
        )
        view.setPlaceholderWithIcon(
            text: "Write Your Idea",
            systemImageName: "sparkles"
        )
        return view
    }()

    // Template seçimi üçün card
    private let templateCard = UIView()
    private let templateTitleLabel = UILabel()
    private let templateSubtitleLabel = UILabel()
    private let templatePreview = UIImageView()
    private let chooseTemplateButton = UIButton(type: .system)

    // Generate button (AIVC stili)
    private let generateButton = UIButton(type: .system)

    // Nəticə card-ı (AIVC ilə eyni MemeResultView)
    private let resultCard = UIView()
    private let resultView = MemeResultView(
        placeholderText: "Your AI meme will appear here"
    )

    // Share card (AIVC ilə eyni MemeShareActionsView)
    private let shareCard = UIView()
    private let shareActionsView = MemeShareActionsView()

    // MARK: - Data

    private var templates: [TemplateDTO] = []
    private var selectedTemplate: TemplateDTO? {
        didSet { updateTemplateCardUI() }
    }

    // MARK: - Init

    override init(viewModel: FromTemplateVM) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mgBackground
        configureNavigation(title: "AI + Template")

        viewModel.loadTemplates()
    }

    // MARK: - BaseController hooks

    override func configureUI() {
        super.configureUI()

        // Scroll + Stack
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        // Prompt card – sadəcə view-in özünü stack-ə qoyuruq (MemePromptView özü card kimi dizaynlanıbsa super),
        // yox əgər yoxdursa, AIVC-dəki kimi ayrıca card içində saxlaya bilərsən.
        styleCard(promptView)

        // Template card
        setupTemplateCard()

        // Generate button – AIVC-dəki stil
        generateButton.applyFilledStyle(
            title: "Generate with Template",
            systemImageName: "sparkles",
            baseBackgroundColor: .mgAccent,
            baseForegroundColor: .mgTextSecondary
        )
        generateButton.layer.cornerRadius = 20
        generateButton.clipsToBounds = false

        // Result + Share cardlar
        styleCard(resultCard)
        resultCard.addSubview(resultView)

        styleCard(shareCard)
        shareCard.addSubview(shareActionsView)
        shareCard.isHidden = true
        // Stack sırası (AIVC pattern)
        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(templateCard)
        stackView.addArrangedSubview(generateButton)
        stackView.addArrangedSubview(resultCard)
        stackView.addArrangedSubview(shareCard)

        // Actions
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
        super.configureConstraints()

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

        // Template list
        viewModel.onTemplatesLoaded = { [weak self] list in
            self?.templates = list
        }

        // Meme generated
        viewModel.onMemeGenerated = { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                self.resultView.image = image
                self.shareCard.isHidden = false
                self.scrollToResult()
            }
        }

        // Loading state – AIVC ilə eyni davranış
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self else { return }

            self.generateButton.isEnabled = !isLoading
            self.generateButton.alpha = isLoading ? 0.6 : 1.0

            if isLoading {
                self.showToast(
                    message: "Cooking your meme in the AI kitchen... 🔥",
                    type: .info
                )
                self.resultView.image = nil
            } else {
                self.showToast(
                    message: "Meme is ready! 🧀",
                    type: .success
                )
            }
        }

        viewModel.onError = { [weak self] message in
            self?.showToast(message: message, type: .error)
        }
    }

    // MARK: - Template Card

    private func setupTemplateCard() {
        styleCard(templateCard)

        templateTitleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        templateTitleLabel.textColor = .mgTextPrimary
        templateTitleLabel.text = "Choose a Template"

        templateSubtitleLabel.font = .systemFont(ofSize: 14)
        templateSubtitleLabel.textColor = .mgTextSecondary
        templateSubtitleLabel.numberOfLines = 0
        templateSubtitleLabel.text = "Pick a classic meme format. You can change it later."

        templatePreview.contentMode = .scaleAspectFill
        templatePreview.layer.cornerRadius = 16
        templatePreview.layer.masksToBounds = true
        templatePreview.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)

        chooseTemplateButton.setTitle("Select Template", for: .normal)
        chooseTemplateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        chooseTemplateButton.setTitleColor(.mgTextPrimary, for: .normal)
        chooseTemplateButton.addTarget(
            self,
            action: #selector(handleChooseTemplateTapped),
            for: .touchUpInside
        )

        let bottomRow = UIStackView(arrangedSubviews: [templatePreview, chooseTemplateButton])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 12

        templatePreview.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }

        let contentStack = UIStackView(arrangedSubviews: [
            templateTitleLabel,
            templateSubtitleLabel,
            bottomRow
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 8

        templateCard.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func updateTemplateCardUI() {
        guard let template = selectedTemplate else {
            templateSubtitleLabel.text = "Pick a classic meme format. You can change it later."
            chooseTemplateButton.setTitle("Select Template", for: .normal)
            templatePreview.image = nil
            templatePreview.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)
            return
        }
        templateSubtitleLabel.text = template.name
        chooseTemplateButton.setTitle("Change Template", for: .normal)
        
        MemeService.shared.loadImage(url: template.url) { [weak self] image in
            DispatchQueue.main.async {
                guard let self else { return }
                self.templatePreview.image = image
                self.templatePreview.backgroundColor = .clear
            }
        }
    }

    // MARK: - Helpers

    private func styleCard(_ view: UIView) {
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
    }

    private func scrollToResult() {
        view.layoutIfNeeded()
        let rect = resultCard.convert(resultCard.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }

    // MARK: - Actions

    @objc private func handleGenerateTapped() {
        view.endEditing(true)
        viewModel.generateMeme(prompt: promptView.text)
    }

    private func retryGenerate() {
        handleGenerateTapped()
    }

    @objc private func handleChooseTemplateTapped() {
        guard !templates.isEmpty else {
            showToast(message: "Templates are loading. Please try again.", type: .info)
            return
        }

        let picker = TemplatePickerViewController(templates: templates)
        picker.onTemplateSelected = { [weak self] template in
            guard let self else { return }
            self.selectedTemplate = template
            self.viewModel.selectTemplate(id: template.id)
        }

        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(picker, animated: true)
    }
    
    private func resetForNewMeme() {
        view.endEditing(true)
        promptView.text = ""
        resultView.image = nil
        shareCard.isHidden = true

        selectedTemplate = nil
        viewModel.clearSelectedTemplate()

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
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(vc, animated: true)
    }
}
