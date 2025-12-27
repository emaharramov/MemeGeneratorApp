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

    private let mode: MyMemesMode
    private var items: [MyMemeViewData] = []
    private var cancellables = Set<AnyCancellable>()

    private var currentPage: Int = 1
    private var isLoadingMore: Bool = false
    private var hasMorePages: Bool = true

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
        cv.register(MyMemeCell.self, forCellWithReuseIdentifier: MyMemeCell.reuseID)
        return cv
    }()

    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Palette.mgAccent
        return rc
    }()

    init(mode: MyMemesMode, viewModel: MyMemesVM) {
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
        view.addSubviews(collectionView, emptyStateView)

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    @objc private func onRefresh() {
        resetPagination()
        fetchData()
    }

    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        isLoadingMore = false
        items.removeAll()
    }

    private func fetchData(isLoadingMore: Bool = false) {
        if !isLoadingMore {
            items.removeAll()
            collectionView.reloadData()
        }

        switch mode {
        case .ai:
            viewModel.getAiMemes(page: currentPage)
        case .aiTemplate:
            viewModel.getAiTemplateMemes(page: currentPage)
        }

        updateEmptyState()
    }

    private func loadMoreIfNeeded() {
        guard !isLoadingMore, hasMorePages else { return }

        isLoadingMore = true
        currentPage += 1
        fetchData(isLoadingMore: true)
    }

    private func updateEmptyState() {
        let isEmpty: Bool

        switch mode {
        case .ai:
            isEmpty = (viewModel.aiMemes?.memes?.isEmpty ?? true) && currentPage == 1
        case .aiTemplate:
            isEmpty = (viewModel.aiTempMemes?.memes?.isEmpty ?? true) && currentPage == 1
        }

        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

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
                top: 8, leading: 8, bottom: 24, trailing: 8
            )
            sectionLayout.interGroupSpacing = 4
            return sectionLayout
        }
    }

    override func bindViewModel() {
        viewModel.$aiMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] response in
                guard let self else { return }
                guard self.mode == .ai else { return }

                let memes = response?.memes ?? []

                self.hasMorePages = !memes.isEmpty

                let newItems = memes.map { meme in
                    MyMemeViewData(
                        imageURL: meme.imageURL,
                        title: meme.prompt ?? "",
                        badgeText: self.mode.badgeText,
                        createdAtText: meme.createdAt?.timeAgoString() ?? ""
                    )
                }

                if self.currentPage == 1 {
                    self.items = newItems
                } else {
                    self.items.append(contentsOf: newItems)
                }

                self.isLoadingMore = false
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
                self.hasMorePages = !memes.isEmpty

                let newItems = memes.map { meme in
                    let top = meme.topText ?? ""
                    let bottom = meme.bottomText ?? ""
                    let title = [top, bottom].filter { !$0.isEmpty }.joined(separator: "\n")

                    return MyMemeViewData(
                        imageURL: meme.imageURL,
                        title: title,
                        badgeText: self.mode.badgeText,
                        createdAtText: meme.createdAt?.timeAgoString() ?? ""
                    )
                }

                if self.currentPage == 1 {
                    self.items = newItems
                } else {
                    self.items.append(contentsOf: newItems)
                }

                self.isLoadingMore = false
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                self.updateEmptyState()
            }
            .store(in: &cancellables)
    }

    // MARK: - Collection

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyMemeCell = collectionView.dequeueCell(MyMemeCell.self, for: indexPath)

        let item = items[indexPath.item]
        cell.configure(with: item)

        cell.onDownloadTapped = { [weak self] image in
            guard let self, let image else { return }
            self.saveImageToPhotos(image)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let totalItems = items.count
        if indexPath.item >= totalItems - 2 {
            loadMoreIfNeeded()
        }
    }

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos", type: .success)
    }
}
