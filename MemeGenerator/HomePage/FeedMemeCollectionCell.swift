//
//  FeedMemeCollectionCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit
import SnapKit

final class FeedMemeCollectionCell: UICollectionViewCell {
    
    static let reuseId = "FeedMemeCollectionCell"

    private let memeImageView = UIImageView()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .label
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bookmark"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let labelsStack = UIStackView()
    private let iconsStack = UIStackView()
    private let topRowStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.backgroundColor = .clear

        memeImageView.layer.cornerRadius = 10
        memeImageView.clipsToBounds = true
        memeImageView.contentMode = .scaleAspectFill
        contentView.addSubview(memeImageView)

        labelsStack.axis = .vertical
        labelsStack.spacing = 1
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)

        iconsStack.axis = .horizontal
        iconsStack.spacing = 8
        iconsStack.addArrangedSubview(bookmarkButton)
        iconsStack.addArrangedSubview(shareButton)

        topRowStack.axis = .horizontal
        topRowStack.alignment = .top
        topRowStack.distribution = .fill
        topRowStack.spacing = 8

        let spacer = UIView()
        topRowStack.addArrangedSubview(labelsStack)
        topRowStack.addArrangedSubview(spacer)
        topRowStack.addArrangedSubview(iconsStack)

        contentView.addSubview(topRowStack)
    }

    private func setupConstraints() {
        memeImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(200)
        }

        topRowStack.snp.makeConstraints {
            $0.top.equalTo(memeImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(8)
        }
    }

    func configure(template: MemesTemplate, index: Int) {
        titleLabel.text = template.topText ?? "Meme #\(index + 1)"
        subtitleLabel.text = template.bottomText ?? ""
        memeImageView.loadImage(template.imageURL ?? "")
    }
}
