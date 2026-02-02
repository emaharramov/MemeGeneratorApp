//
//  FeedController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import SnapKit
import Combine

final class FeedController: BaseController<FeedViewModel> {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.register(FeedMemeCollectionCell.self, forCellWithReuseIdentifier: FeedMemeCollectionCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Palette.mgAccent
        return rc
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        setupUI()
        bindViewModel()
        viewModel.loadPage(1)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    @objc private func onRefresh() {
        viewModel.loadPage(1)
    }

    override func bindViewModel() {
        super.bindViewModel()

        viewModel.$allAIMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.refreshControl.endRefreshing()
                self?.showToast(message: message)
            }
            .store(in: &cancellables)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(420)
                )
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(420)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 32, trailing: 0)
            section.interGroupSpacing = 12
            return section
        }
    }

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos", type: .success)
    }
}

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.allAIMemes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < viewModel.allAIMemes.count else {
            return UICollectionViewCell()
        }

        let cell: FeedMemeCollectionCell = collectionView.dequeueCell(FeedMemeCollectionCell.self, for: indexPath)
        let meme = viewModel.allAIMemes[indexPath.item]
        cell.configure(template: meme)
        cell.onDownloadTapped = { [weak self] image in
            guard let self, let image else { return }
            self.saveImageToPhotos(image)
        }
        return cell
    }
}

extension FeedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let count = viewModel.allAIMemes.count
        if indexPath.item >= count - 2 && viewModel.hasNext {
            viewModel.loadNextPage()
        }
    }
}
