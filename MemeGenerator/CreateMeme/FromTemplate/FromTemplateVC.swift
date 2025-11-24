//
//  FromTemplateVC.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class FromTemplateVC: BaseController<FromTemplateVM> {

    private enum Section: Int, CaseIterable {
        case prompt
        case templates
        case actions
        case result
        case shareActions
    }

    private var templates: [TemplateDTO] = []
    private var generatedImage: UIImage?

    private let collectionView: UICollectionView

    // 3 sütun, 3 sətir görünməsini istəyirik
    private let templatesColumns: CGFloat = 3
    private let templateVisibleRows: CGFloat = 3

    // Gradient background
    private let backgroundGradient = CAGradientLayer()

    // MARK: - Init

    init(userId: String) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        super.init(viewModel: FromTemplateVM(userId: userId))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupCollectionView()
        registerCells()
        setupBindings()

        viewModel.loadTemplates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    // MARK: - Setup

    private func setupGradientBackground() {
        backgroundGradient.colors = [
            UIColor.systemPink.withAlphaComponent(0.9).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.8).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.9).cgColor
        ]
        backgroundGradient.locations = [0.0, 0.45, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint   = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        collectionView.showsVerticalScrollIndicator = false

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func registerCells() {
        collectionView.register(PromptCell.self,
                                forCellWithReuseIdentifier: PromptCell.id)

        collectionView.register(ActionsCell.self,
                                forCellWithReuseIdentifier: ActionsCell.id)

        collectionView.register(TemplateGridCell.self,
                                forCellWithReuseIdentifier: TemplateGridCell.id)

        collectionView.register(ResultCell.self,
                                forCellWithReuseIdentifier: ResultCell.id)

        collectionView.register(ShareActionsCell.self,
                                forCellWithReuseIdentifier: ShareActionsCell.id)
    }

    private func setupBindings() {
        viewModel.onTemplatesLoaded = { [weak self] list in
            self?.templates = list
            self?.collectionView.reloadSections(
                IndexSet(integer: Section.templates.rawValue)
            )
        }

        viewModel.onMemeGenerated = { [weak self] image in
            guard let self else { return }
            self.generatedImage = image

            let reloadSections = IndexSet([
                Section.result.rawValue,
                Section.shareActions.rawValue
            ])
            self.collectionView.reloadSections(reloadSections)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.collectionView.layoutIfNeeded()
                self.scrollToResultSection()
            }
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

    // MARK: - Helpers

    private func currentPromptText() -> String {
        let indexPath = IndexPath(item: 0, section: Section.prompt.rawValue)
        guard let cell = collectionView.cellForItem(at: indexPath) as? PromptCell
        else { return "" }

        return cell.text
    }

    /// Result section görünürsə ona scroll edir
    private func scrollToResultSection() {
        let sectionIndex = Section.result.rawValue

        guard collectionView.numberOfSections > sectionIndex,
              collectionView.numberOfItems(inSection: sectionIndex) > 0 else {
            return
        }

        let indexPath = IndexPath(item: 0, section: sectionIndex)
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredVertically,
            animated: true
        )
    }

    // MARK: - Actions

    @objc private func handleGenerateButtonTapped(_ sender: UIButton) {
        let prompt = currentPromptText()
        viewModel.generateMeme(prompt: prompt)
    }

    @objc private func handleNewButtonTapped(_ sender: UIButton) {
        generatedImage = nil
        collectionView.reloadSections(
            IndexSet([Section.result.rawValue, Section.shareActions.rawValue])
        )
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

// MARK: - UICollectionViewDataSource

extension FromTemplateVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .prompt:       return 1
        case .templates:    return 1        // yalnız 1 grid cell
        case .actions:      return 1
        case .result:       return generatedImage == nil ? 0 : 1
        case .shareActions: return generatedImage == nil ? 0 : 1
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let sectionType = Section(rawValue: indexPath.section)!

        switch sectionType {

        case .prompt:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PromptCell.id, for: indexPath
            ) as! PromptCell

            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.92)

            return cell

        case .actions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActionsCell.id, for: indexPath
            ) as! ActionsCell

            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)

            cell.onGenerate.addTarget(
                self,
                action: #selector(handleGenerateButtonTapped(_:)),
                for: .touchUpInside
            )

            cell.onNewButton.addTarget(
                self,
                action: #selector(handleNewButtonTapped(_:)),
                for: .touchUpInside
            )
            return cell

        case .templates:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TemplateGridCell.id,
                for: indexPath
            ) as! TemplateGridCell

            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)

            cell.templates = templates
            cell.onTemplateSelected = { [weak self] template in
                self?.viewModel.selectTemplate(id: template.id)
            }
            return cell

        case .result:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ResultCell.id, for: indexPath
            ) as! ResultCell

            cell.contentView.layer.cornerRadius = 18
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.95)

            cell.imageView.image = generatedImage
            return cell

        case .shareActions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShareActionsCell.id, for: indexPath
            ) as! ShareActionsCell

            cell.contentView.layer.cornerRadius = 14
            cell.contentView.layer.masksToBounds = true
            cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.95)

            cell.onSave = { [weak self] in
                self?.saveImageToPhotos()
            }

            cell.onShare = { [weak self] in
                self?.shareMeme()
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FromTemplateVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sectionType = Section(rawValue: indexPath.section)!
        let fullWidth = collectionView.bounds.width
        let horizontalInset: CGFloat = 16
        let width = fullWidth - horizontalInset * 2

        switch sectionType {
        case .prompt:
            return CGSize(width: width, height: 110)

        case .actions:
            return CGSize(width: width, height: 64)

        case .templates:
            let spacing: CGFloat = 12
            let totalSpacingHoriz = (templatesColumns - 1) * spacing
            let availableWidth = width - totalSpacingHoriz
            let itemWidth = floor(availableWidth / templatesColumns)

            let rows = templateVisibleRows
            let totalSpacingVert = (rows - 1) * spacing
            let height = rows * itemWidth + totalSpacingVert + 10 + 10

            return CGSize(width: width, height: height)

        case .result:
            return CGSize(width: width, height: 350)

        case .shareActions:
            return CGSize(width: width, height: 64)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        guard let sectionType = Section(rawValue: section) else {
            return .zero
        }

        switch sectionType {
        case .prompt:
            return UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
        case .templates:
            return UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
        case .actions:
            return UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        case .result:
            return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        case .shareActions:
            return UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        }
    }
}
