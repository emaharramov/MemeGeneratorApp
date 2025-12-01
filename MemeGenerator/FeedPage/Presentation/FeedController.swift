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

    // Status bar ikonları üçün
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Section

    private enum Section: Int, CaseIterable {
        case feed
    }

    // MARK: - UI

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
        rc.tintColor = .mgAccent
        return rc
    }()

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    override init(viewModel: FeedViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Feed"
        view.backgroundColor = .mgBackground

        setupSubviews()
        setupConstraints()
        setupCollectionView()
        bindViewModel()

        viewModel.getAllMemes()
    }

    // MARK: - Setup

    private func setupSubviews() {
        view.addSubview(collectionView)
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

    // MARK: - Bindings

    override func bindViewModel() {
        super.bindViewModel()

        // data
        viewModel.$allMemes
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // error
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self else { return }
                self.refreshControl.endRefreshing()
                self.showToast(message: message)
            }
            .store(in: &cancellables)

        // loading
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

    // MARK: - Layout

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

    // MARK: - Helpers

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast(message: "Saved to Photos")
    }
}

// MARK: - DataSource

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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedMemeCollectionCell.reuseId,
                for: indexPath
            ) as? FeedMemeCollectionCell else {
                fatalError("Wrong cell type")
            }

            let template = viewModel.allMemes[indexPath.item]
            cell.configure(template: template)

            cell.onDownloadTapped = { [weak self] image in
                guard let self, let image else { return }
                self.saveImageToPhotos(image)
            }

            cell.onSaveTapped = { [weak self] _ in
                guard let self else { return }
                self.showToast(message: "Saved in App")
            }

            return cell
        }
    }
}

// MARK: - Delegate

extension FeedController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        // gələcəkdə detail açmaq üçün
    }
}
