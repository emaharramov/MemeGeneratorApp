//
//  FromTemplateVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit
import Combine

final class FromTemplateVC: BaseController<FromTemplateVM> {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let refreshControl = UIRefreshControl()

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

    private let templateSelectionView = TemplateSelectionView()

    private let generateButton = UIButton(type: .system)

    private let resultCard = UIView()
    private let resultView = MemeResultView(
        placeholderText: "Your AI meme will appear here"
    )

    private let shareCard = UIView()
    private let shareActionsView = MemeShareActionsView()

    private var templates: [TemplateDTO] = []
    private var selectedTemplate: TemplateDTO? {
        didSet { updateTemplateCardUI() }
    }

    private var didRequestGeneration = false
    private var cancellables = Set<AnyCancellable>()

    override init(viewModel: FromTemplateVM) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        configureNavigation(title: "AI + Template")

        viewModel.loadTemplates()
    }

    override func configureUI() {
        super.configureUI()

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        refreshControl.tintColor = Palette.mgAccent
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl

        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        styleCard(promptView)

        templateSelectionView.configureInitialState()
        templateSelectionView.onButtonTapped = { [weak self] in
            self?.handleChooseTemplateTapped()
        }

        generateButton.applyFilledStyle(
            title: "Generate with Template",
            systemImageName: "sparkles",
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextSecondary
        )
        generateButton.layer.cornerRadius = 20
        generateButton.clipsToBounds = false

        styleCard(resultCard)
        resultCard.addSubview(resultView)

        styleCard(shareCard)
        shareCard.addSubview(shareActionsView)
        shareCard.isHidden = true

        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(templateSelectionView)
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
        viewModel.onMemeGenerated = { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                self.resultView.image = image
                self.shareCard.isHidden = (image == nil)
                if image != nil {
                    self.scrollToResult()
                }
            }
        }

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self else { return }

                self.generateButton.isEnabled = !isLoading
                self.generateButton.alpha = isLoading ? 0.6 : 1.0

                guard self.didRequestGeneration else { return }

                if isLoading {
                    self.showToast(
                        message: "Cooking your meme in the AI kitchen... 🔥",
                        type: .info
                    )
                    self.resultView.image = nil
                    self.shareCard.isHidden = true
                } else if self.resultView.image != nil {
                    self.showToast(
                        message: "Meme is ready! 🧀",
                        type: .success
                    )
                }
            }
            .store(in: &cancellables)

        viewModel.onTemplatesLoaded = { [weak self] list in
            self?.templates = list
            self?.showToast(
                message: "Now you can choose one of your favorite templates!",
                type: .success
            )
        }
    }

    private func updateTemplateCardUI() {
        guard let template = selectedTemplate else {
            templateSelectionView.configureInitialState()
            return
        }

        templateSelectionView.updateForSelectedTemplate(
            name: template.name,
            previewImage: nil
        )

        MemeService.shared.loadImage(url: template.url) { [weak self] image in
            DispatchQueue.main.async {
                guard let self else { return }
                self.templateSelectionView.updateForSelectedTemplate(
                    name: template.name,
                    previewImage: image
                )
            }
        }
    }

    private func styleCard(_ view: UIView) {
        view.backgroundColor = Palette.mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
    }

    private func scrollToResult() {
        view.layoutIfNeeded()
        let rect = resultCard.convert(resultCard.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -16), animated: true)
    }

    @objc private func retryGenerate() {
        view.endEditing(true)
        guard let prompt = validatePrompt(promptView.text) else { return }
        didRequestGeneration = true
        viewModel.generateMeme(prompt: prompt)
    }

    @objc private func handleChooseTemplateTapped() {
        guard !templates.isEmpty else {
            showToast(
                message: "Templates are loading. Please try again.",
                type: .info
            )
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

    @objc private func handleRefresh() {
        resetForNewMeme()
        refreshControl.endRefreshing()
    }

    private func resetForNewMeme() {
        view.endEditing(true)
        promptView.text = ""
        resultView.image = nil
        shareCard.isHidden = true

        selectedTemplate = nil
        viewModel.clearSelectedTemplate()
        scrollView.scrollToTop()
        didRequestGeneration = false
    }

    private func saveImageToPhotos() {
        saveToPhotos(resultView.image)
    }

    private func shareMeme() {
        shareImage(resultView.image, from: resultView)
    }
}
