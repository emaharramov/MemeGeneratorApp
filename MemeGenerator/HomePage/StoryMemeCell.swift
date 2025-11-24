//
//  StoryMemeCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class StoryMemeCell: UICollectionViewCell {
    static let reuseId = "StoryMemeCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(4)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, imageUrl: String) {
        titleLabel.text = title
        imageView.loadImage(imageUrl)
    }

    func configure(template: MemesTemplate) {
        titleLabel.text = template.userID ?? "user"
        imageView.loadImage(template.imageURL ?? "")
    }
}
