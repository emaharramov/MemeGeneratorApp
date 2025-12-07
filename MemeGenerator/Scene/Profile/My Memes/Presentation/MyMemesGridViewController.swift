//
//  MyMemesGridViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit
import Combine

final class MyMemesGridViewController: BaseController<MyMemesVM>,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate {

    enum Mode {
        case ai
        case aiTemplate
    }

    private let mode: Mode
    private var items: [MyMemeViewData] = []
    private var cancellables = Set<AnyCancellable>()

    private let emptyStateView = EmptyStateView(
        title: "No memes yet",
        subtitle: "This place is awkwardly empty.\nCreate or generate a meme to see it here."
    )

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(
            MyMemeCell.self,
            forCellWithReuseIdentifier: MyMemeCell.reuseID
        )
        return cv
    }()

    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Palette.mgAccent
        return rc
    }()

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(260)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(260)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(4)

            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 24,
                trailing: 8
            )
            sectionLayout.interGroupSpacing = 4
            return sectionLayout
        }
    }

    init(mode: Mode, viewModel: MyMemesVM) {
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        setupLayout()
        bindViewModel()
        fetchData()
    }

    private func setupLayout() {
        view.addSubview(collectionView)

        collectionView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    @objc private func onRefresh() {
        viewModel.getAiMemes()
        viewModel.getAiTemplateMemes()
    }

    private func updateEmptyState() {
        let isEmpty: Bool

        switch mode {
        case .ai:
            isEmpty = viewModel.aiMemes?.memes?.isEmpty ?? true
        case .aiTemplate:
            isEmpty = viewModel.aiTempMemes?.memes?.isEmpty ?? true
        }

        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func fetchData() {
        items.removeAll()
        collectionView.reloadData()
        updateEmptyState()

        switch mode {
        case .ai:
            viewModel.getAiMemes()
        case .aiTemplate:
            viewModel.getAiTemplateMemes()
        }
    }

    override func bindViewModel() {
        viewModel.$aiMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] response in
                guard let self else { return }
                guard self.mode == .ai else { return }

                let memes = response?.memes ?? []

                let mapped: [MyMemeViewData] = memes.compactMap { meme in
                    let title = meme.prompt ?? ""
                    let createdText = meme.createdAt?.timeAgoString() ?? ""

                    return MyMemeViewData(
                        imageURL: meme.imageURL,
                        title: title,
                        badgeText: "AI",
                        createdAtText: createdText
                    )
                }

                if self.mode == .ai {
                    self.items = mapped
                } else {
                    self.items.append(contentsOf: mapped)
                }

                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.$aiTempMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] response in
                guard let self else { return }
                guard self.mode == .aiTemplate else { return }

                let memes = response?.memes ?? []

                let mapped: [MyMemeViewData] = memes.compactMap { meme in
                    let top = meme.topText ?? ""
                    let bottom = meme.bottomText ?? ""
                    let title: String

                    if !top.isEmpty && !bottom.isEmpty {
                        title = "\(top)\n\(bottom)"
                    } else if !top.isEmpty {
                        title = top
                    } else {
                        title = bottom
                    }

                    let createdText = meme.createdAt?.timeAgoString() ?? ""

                    return MyMemeViewData(
                        imageURL: meme.imageURL,
                        title: title,
                        badgeText: "AI+T",
                        createdAtText: createdText
                    )
                }

                if self.mode == .aiTemplate {
                    self.items = mapped
                } else {
                    self.items.append(contentsOf: mapped)
                }

                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyMemeCell = collectionView.dequeueCell(
            MyMemeCell.self,
            for: indexPath
        )

        let item = items[indexPath.item]
        cell.configure(with: item)
        cell.onDownloadTapped = { [weak self] image in
            guard let self, let image else { return }
            self.saveImageToPhotos(image)
        }
        return cell
    }

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos", type: .success)
    }
}
