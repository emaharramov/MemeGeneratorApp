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

    private let cardView = UIView()
    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        cardView.backgroundColor = .mgCard
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.mgCardStroke.cgColor

        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16))
            make.height.equalTo(56)
        }

        iconBackground.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        iconBackground.layer.cornerRadius = 12
        iconBackground.snp.makeConstraints { $0.width.height.equalTo(36) }

        iconView.tintColor = .mgAccent
        iconView.contentMode = .scaleAspectFit

        iconBackground.addSubview(iconView)
        iconView.snp.makeConstraints { $0.center.equalToSuperview() }

        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .mgTextPrimary

        chevron.tintColor = .mgTextSecondary

        let stack = UIStackView(arrangedSubviews: [iconBackground, titleLabel, UIView(), chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        cardView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(iconName: String,
                   title: String,
                   isDestructive: Bool = false) {
        iconView.image = UIImage(systemName: iconName)
        titleLabel.text = title

        if isDestructive {
            titleLabel.textColor = UIColor.systemRed.withAlphaComponent(0.9)
            iconView.tintColor = UIColor.systemRed.withAlphaComponent(0.9)
        } else {
            titleLabel.textColor = .mgTextPrimary
            iconView.tintColor = .mgAccent
        }
    }
}
