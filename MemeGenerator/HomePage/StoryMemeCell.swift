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

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let ringView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func configureUI() {
        contentView.backgroundColor = .clear

        ringView.layer.cornerRadius = 36
        ringView.layer.masksToBounds = true
        // sadə border – gradient istəsən sonradan əlavə edərsən
        ringView.layer.borderWidth = 2
        ringView.layer.borderColor = UIColor.systemPink.cgColor

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 32

        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1

        contentView.addSubview(ringView)
        ringView.addSubview(imageView)
        contentView.addSubview(nameLabel)
    }

    private func configureConstraints() {
        ringView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }

        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(64)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(ringView.snp.bottom).offset(4)
            $0.left.right.equalToSuperview()
        }
    }

    func configure(template: MemesTemplate) {
        nameLabel.text = template.userID ?? "user"
        imageView.loadImage(template.imageURL ?? "")
    }
}
