//
//  ProfileMenuCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileMenuCell: UITableViewCell {

    static let reuseID = "ProfileMenuCell"

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true

        contentView.addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16))
            make.height.equalTo(52)
        }

        iconBackground.backgroundColor = .systemGray6
        iconBackground.layer.cornerRadius = 12
        iconBackground.snp.makeConstraints { $0.width.height.equalTo(36) }

        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit

        iconBackground.addSubview(iconView)
        iconView.snp.makeConstraints { $0.center.equalToSuperview() }

        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .label

        chevron.tintColor = .tertiaryLabel

        let stack = UIStackView(arrangedSubviews: [iconBackground, titleLabel, UIView(), chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(iconName: String, title: String) {
        iconView.image = UIImage(systemName: iconName)
        titleLabel.text = title
    }
}
