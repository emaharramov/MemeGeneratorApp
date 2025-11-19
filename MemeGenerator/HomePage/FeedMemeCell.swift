//
//  FeedMemeCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class FeedMemeCell: UITableViewCell {

    static let reuseId = "FeedMemeCell"

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // Meme image
        memeImageView.layer.cornerRadius = 10
        memeImageView.clipsToBounds = true
        memeImageView.contentMode = .scaleAspectFill
        contentView.addSubview(memeImageView)

        // Labels stack
        labelsStack.axis = .vertical
        labelsStack.spacing = 1       // daha kompakt
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)

        // Icons stack
        iconsStack.axis = .horizontal
        iconsStack.spacing = 8    
        iconsStack.addArrangedSubview(bookmarkButton)
        iconsStack.addArrangedSubview(shareButton)

        // Top row stack
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
            $0.top.equalToSuperview().offset(8)                // 12 → 8 (daha kompakt)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(200)                            // 200 → 180 (azca balaca)
        }

        topRowStack.snp.makeConstraints {
            $0.top.equalTo(memeImageView.snp.bottom).offset(8) // 8 qaldı → ideal
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(8)             // 12 → 8 (daha kompakt)
        }
    }

    func configure(title: String, subtitle: String, imageUrl: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        memeImageView.loadImage(imageUrl)
    }
}
