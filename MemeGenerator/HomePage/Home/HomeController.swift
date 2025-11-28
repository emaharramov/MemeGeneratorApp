//
//  HomeController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import SnapKit

final class HomeController: BaseController<HomeViewModel> {

    // MARK: - Sections

    private enum Section: Int, CaseIterable {
        case feed
    }

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.register(FeedMemeCollectionCell.self,
                    forCellWithReuseIdentifier: FeedMemeCollectionCell.reuseId)
        return cv
    }()

    private let refreshControl = UIRefreshControl()
    
    override init(viewModel: HomeViewModel) {
         super.init(viewModel: viewModel)
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Memes"

        setupSubviews()
        setupConstraints()
        setupCollectionView()
        bindViewModel()
        view.backgroundColor = .white
        viewModel.getAllTemplates()
    }

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
        refreshControl.addTarget(self,
                                 action: #selector(onRefresh),
                                 for: .valueChanged)
    }

    @objc private func onRefresh() {
        viewModel.getAllTemplates()
    }

    // MARK: - ViewModel binding

    override func bindViewModel() {
        viewModel.stateUpdated = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loading:
                break

            case .success, .loaded:
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()

            case .error(let message):
                self.refreshControl.endRefreshing()
                print("Home error:", message)

            default:
                break
            }
        }
    }

    // MARK: - Layout

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .feed:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 0,
                    bottom: 16,
                    trailing: 0
                )
                sectionLayout.interGroupSpacing = 8
                return sectionLayout
            }
        }
    }
}

// MARK: - DataSource

extension HomeController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .feed:
            return viewModel.allTemplates.count
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

            let template = viewModel.allTemplates[indexPath.item]
            cell.configure(template: template)
            return cell
        }
    }
}

// MARK: - Delegate

extension HomeController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard let sectionType = Section(rawValue: indexPath.section) else { return }

        switch sectionType {
        case .feed:
            break
        }
    }
}
