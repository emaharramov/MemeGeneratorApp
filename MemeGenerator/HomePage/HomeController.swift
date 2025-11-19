//
//  HomeController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import SnapKit

final class HomeController: BaseController<BaseViewModel> {
    
    let stories = [
        Story(imageUrl: "https://i.imgflip.com/1bij.jpg", duration: 5),
        Story(imageUrl: "https://i.imgflip.com/26am.jpg", duration: 5),
        Story(imageUrl: "https://i.imgflip.com/2fm6x.jpg", duration: 5)
    ]

    // Story-style top memes
    private let storiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(StoryMemeCell.self, forCellWithReuseIdentifier: StoryMemeCell.reuseId)
        return cv
    }()

    // Main feed
    private let feedTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = true
        tv.register(FeedMemeCell.self, forCellReuseIdentifier: FeedMemeCell.reuseId)
        tv.backgroundColor = .clear
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Memes"

        setupSubviews()
        setupConstraints()
        setupDelegates()
    }

    private func setupSubviews() {
        [
            storiesCollectionView,
            feedTableView
        ].forEach(view.addSubview)
    }

    private func setupConstraints() {
        storiesCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(96)     // Story hündürlüyü
        }

        feedTableView.snp.makeConstraints {
            $0.top.equalTo(storiesCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupDelegates() {
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self

        feedTableView.dataSource = self
        feedTableView.delegate = self
    }
}

// MARK: - CollectionView (Stories)

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // placeholder
        return stories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StoryMemeCell.reuseId,
            for: indexPath
        ) as! StoryMemeCell
        
        let story = stories[indexPath.item]
        
        cell.configure(
            title: "User \(indexPath.item + 1)",
            imageUrl: story.imageUrl
        )
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stories = [
            Story(imageUrl: "https://i.imgflip.com/1bij.jpg", duration: 5),
            Story(imageUrl: "https://i.imgflip.com/26am.jpg", duration: 5),
            Story(imageUrl: "https://i.imgflip.com/2fm6x.jpg", duration: 5)
        ]
        
        let group = StoryGroup(
            username: "mememaster",
            avatarUrl: nil,
            stories: stories
        )
        
        let viewer = StoryViewerController(group: group)
        present(viewer, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 72, height: 96)
    }
}

// MARK: - TableView (Feed)

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FeedMemeCell.reuseId,
            for: indexPath
        ) as! FeedMemeCell
        let story = stories[indexPath.item]
        
        cell.configure(
            title: "Funny meme #\(indexPath.row + 1)",
            subtitle: "Dark • 1.2K likes",
            imageUrl: story.imageUrl
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        320
    }
}
