//
//  AIMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class AIMemeViewController: UIViewController {

    private enum Section: Int, CaseIterable {
        case prompt
        case templates
        case actions
        case result
        case shareActions
    }

    private let viewModel: AIMemeViewModel
    private var templates: [TemplateDTO] = []
    private var generatedImage: UIImage?

    private let collectionView: UICollectionView

    // 3 sütun, 3 sətir görünməsini istəyirik
    private let templatesColumns: CGFloat = 3
    private let templateVisibleRows: CGFloat = 3

    // MARK: - Init

    init(userId: String) {
        self.viewModel = AIMemeViewModel(userId: userId)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        self.collectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupCollectionView()
        registerCells()
        setupBindings()

        viewModel.loadTemplates()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.contentInset.bottom = 24

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
        let activityVC = UIActivityViewController(activityItems: [image],
                                                  applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension AIMemeViewController: UICollectionViewDataSource {

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
            return cell

        case .actions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActionsCell.id, for: indexPath
            ) as! ActionsCell

            cell.onGenerate.addTarget(self,
                                      action: #selector(handleGenerateButtonTapped(_:)),
                                      for: .touchUpInside)

            cell.onNewButton.addTarget(self,
                                       action: #selector(handleNewButtonTapped(_:)),
                                       for: .touchUpInside)
            return cell

        case .templates:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TemplateGridCell.id,
                for: indexPath
            ) as! TemplateGridCell

            cell.templates = templates
            cell.onTemplateSelected = { [weak self] template in
                self?.viewModel.selectTemplate(id: template.id)
            }
            return cell

        case .result:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ResultCell.id, for: indexPath
            ) as! ResultCell
            cell.imageView.image = generatedImage
            return cell

        case .shareActions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShareActionsCell.id, for: indexPath
            ) as! ShareActionsCell

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

extension AIMemeViewController: UICollectionViewDelegateFlowLayout {

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
            return CGSize(width: width, height: 60)

        case .templates:
            let spacing: CGFloat = 12
            let totalSpacingHoriz = (templatesColumns - 1) * spacing
            let availableWidth = width - totalSpacingHoriz
            let itemWidth = floor(availableWidth / templatesColumns)

            let rows = templateVisibleRows
            let totalSpacingVert = (rows - 1) * spacing
            let height = rows * itemWidth + totalSpacingVert + 5 + 10 // üst + alt inset

            return CGSize(width: fullWidth, height: height)

        case .result:
            return CGSize(width: width, height: 350)

        case .shareActions:
            return CGSize(width: width, height: 60)
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
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        case .actions:
            return UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        case .result:
            return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        case .shareActions:
            return UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        }
    }
}
