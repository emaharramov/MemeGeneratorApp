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

    private let titleLabel = UILabel()

    // 3 sütun (screenshotdakı kimi)
    private let columns: CGFloat = 3
    private let itemSpacing: CGFloat = 12

    private lazy var innerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate   = self
        cv.register(AIMemeTemplateCell.self,
                    forCellWithReuseIdentifier: AIMemeTemplateCell.id)
        return cv
    }()

    private var selectedTemplateId: String?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.text = "Choose a Template"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label

        contentView.addSubview(titleLabel)
        contentView.addSubview(innerCollectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        innerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
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

        let cell: AIMemeTemplateCell = collectionView.dequeueCell(
            AIMemeTemplateCell.self,
            for: indexPath
        )

        let item = templates[indexPath.item]

        cell.imageView.loadImage(item.url)

        let isSelected = item.id == selectedTemplateId
        cell.setSelected(isSelected)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.item]
        selectedTemplateId = template.id
        collectionView.reloadData()
        onTemplateSelected?(template)
    }

    // item ölçüsü
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let fullWidth = collectionView.bounds.width
        let totalSpacing = (columns - 1) * itemSpacing
        let availableWidth = fullWidth - totalSpacing
        let itemWidth = floor(availableWidth / columns)

        return CGSize(width: itemWidth, height: itemWidth)
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
