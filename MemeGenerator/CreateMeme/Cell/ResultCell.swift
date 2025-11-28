//
//  ResultCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class ResultCell: UICollectionViewCell {

    static let id = "ResultCell"

    private let titleLabel = UILabel()
    private let resultView = MemeResultView(placeholderText: "")
    private let subtitleLabel = UILabel()

    var image: UIImage? {
        didSet { resultView.image = image }
    }

    var subtitleText: String? {
        didSet { subtitleLabel.text = subtitleText }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = .clear

        titleLabel.text = "Your Meme"
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(resultView)
        contentView.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        resultView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(resultView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
}
