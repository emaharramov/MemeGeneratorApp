//
//  TemplateGridCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class TemplateGridCell: UICollectionViewCell {

    static let id = "TemplateGridCell"

    var templates: [TemplateDTO] = [] {
        didSet { innerCollectionView.reloadData() }
    }

    var onTemplateSelected: ((TemplateDTO) -> Void)?

    // 2 sütun + yanlardan margin
    private let columns: CGFloat = 2
    private let sideInset: CGFloat = 16
    private let itemSpacing: CGFloat = 12

    private lazy var innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = true
        cv.dataSource = self
        cv.delegate   = self
        cv.register(AIMemeTemplateCell.self,
                    forCellWithReuseIdentifier: AIMemeTemplateCell.id)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(innerCollectionView)
        innerCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            innerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            innerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            innerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - DataSource & Layout

extension TemplateGridCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        templates.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AIMemeTemplateCell.id,
            for: indexPath
        ) as! AIMemeTemplateCell

        let item = templates[indexPath.item]
        MemeService.shared.loadImage(url: item.url) { img in
            DispatchQueue.main.async {
                cell.imageView.image = img
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.item]
        onTemplateSelected?(template)
    }

    // item ölçüsü – bir az balaca + yanlardan margin
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let fullWidth = collectionView.bounds.width
        let gridWidth = fullWidth - sideInset * 2           // sağ-sol margin
        let totalSpacing = (columns - 1) * itemSpacing      // 1 dənə aralıq
        let availableWidth = gridWidth - totalSpacing
        let itemWidth = floor(availableWidth / columns)

        return CGSize(width: itemWidth, height: itemWidth * 0.9) // bir az “short”
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: sideInset, bottom: 10, right: sideInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }
}
