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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private enum Section: Int, CaseIterable {
        case feed
    }

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.register(
            FeedMemeCollectionCell.self,
            forCellWithReuseIdentifier: FeedMemeCollectionCell.reuseId
        )
        return cv
    }()

    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Palette.mgAccent
        return rc
    }()

    private var cancellables = Set<AnyCancellable>()

    override init(viewModel: FeedViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Feed"
        view.backgroundColor = Palette.mgBackground

        setupSubviews()
        setupConstraints()
        setupCollectionView()
        bindViewModel()

        viewModel.getAllMemes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAllMemes()
    }

    private func setupSubviews() {
        view.addSubviews(collectionView)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(
            self,
            action: #selector(onRefresh),
            for: .valueChanged
        )
    }

    @objc private func onRefresh() {
        viewModel.getAllMemes()
    }

    override func bindViewModel() {
        super.bindViewModel()

        viewModel.$allMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.showToast(message: message)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                if !isLoading {
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .feed:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(420)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(420)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 12,
                    leading: 0,
                    bottom: 32,
                    trailing: 0
                )
                sectionLayout.interGroupSpacing = 12
                return sectionLayout
            }
        }
    }

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos", type: .success)
    }
}

extension FeedController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .feed:
            return viewModel.allMemes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let sectionType = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }

        switch sectionType {
        case .feed:
            let cell: FeedMemeCollectionCell = collectionView.dequeueCell(
                FeedMemeCollectionCell.self,
                for: indexPath
            )

            let template = viewModel.allMemes[indexPath.item]
            cell.configure(template: template)

            cell.onDownloadTapped = { [weak self] image in
                guard let self, let image else { return }
                self.saveImageToPhotos(image)
            }

            return cell
        }
    }
}

extension FeedController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        // future: open detail
    }
}
