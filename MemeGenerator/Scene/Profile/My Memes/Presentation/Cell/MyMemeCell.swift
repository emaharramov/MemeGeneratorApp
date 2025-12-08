//
//  MyMemeCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit

final class MyMemeCell: UICollectionViewCell {
    static let reuseID = "MyMemeCell"

    var onDownloadTapped: ((UIImage?) -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 22
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        return v
    }()

    private let memeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        iv.backgroundColor = Palette.mgBackground.withAlphaComponent(0.35)
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = Palette.mgTextPrimary
        lbl.numberOfLines = 0
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = Palette.mgTextSecondary
        lbl.numberOfLines = 1
        return lbl
    }()

    private let bottomDivider: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCardStroke
        return v
    }()

    private let downloadButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.down")
        btn.setImage(image, for: .normal)
        btn.tintColor = Palette.mgAccent
        btn.backgroundColor = Palette.mgAccentSoft
        btn.layer.cornerRadius = 14
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return btn
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.backgroundColor = .clear

        contentView.addSubviews(cardView)
        cardView.addSubviews(memeImageView,titleLabel, bottomDivider, bottomStack)

        bottomStack.addArrangedSubview(UIView())
        bottomStack.addArrangedSubview(subtitleLabel)
        bottomStack.addArrangedSubview(downloadButton)

        downloadButton.addTarget(
            self,
            action: #selector(handleDownload),
            for: .touchUpInside
        )
    }

    private func configureConstraints() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        memeImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(memeImageView.snp.width).multipliedBy(0.9)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(memeImageView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(10)
        }

//        subtitleLabel.snp.makeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
//            $0.left.right.equalToSuperview().inset(10)
//        }

        bottomDivider.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1 / UIScreen.main.scale)
        }

        bottomStack.snp.makeConstraints {
            $0.top.equalTo(bottomDivider.snp.bottom).offset(6)
            $0.left.right.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(8)
        }

        downloadButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        memeImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with data: MyMemeViewData) {
        memeImageView.loadImage(data.imageURL)
        titleLabel.text = data.title
        subtitleLabel.text = data.createdAtText
    }

    @objc private func handleDownload() {
        onDownloadTapped?(memeImageView.image)
    }
}
