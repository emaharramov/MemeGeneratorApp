//
//  ProfileHeaderCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileHeaderCell: UITableViewCell {

    static let reuseID = "ProfileHeaderCell"

    var onEditProfile: (() -> Void)?
    var onGoPremium: (() -> Void)?

    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()

    private let editButton = UIButton(type: .system)
    private let premiumButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // Avatar
        avatarView.backgroundColor = .systemGray5
        avatarView.layer.cornerRadius = 32
        avatarView.clipsToBounds = true
        avatarView.snp.makeConstraints { $0.width.height.equalTo(64) }

        initialsLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        initialsLabel.textAlignment = .center
        initialsLabel.textColor = .systemGray
        avatarView.addSubview(initialsLabel)
        initialsLabel.snp.makeConstraints { $0.edges.equalToSuperview() }

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .label

        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let topStack = UIStackView(arrangedSubviews: [avatarView, textStack])
        topStack.axis = .horizontal
        topStack.spacing = 12
        topStack.alignment = .center

        configureButton(editButton,
                        title: "Edit Profile",
                        filled: false)
        configureButton(premiumButton,
                        title: "Go Premium",
                        filled: true)

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        premiumButton.addTarget(self, action: #selector(premiumTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [editButton, premiumButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 10
        buttonsStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [topStack, buttonsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true

        contentView.addSubview(card)
        card.addSubview(mainStack)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }

        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func configureButton(_ button: UIButton,
                                 title: String,
                                 filled: Bool) {
        if filled {
            button.applyFilledStyle(
                title: title,
                baseBackgroundColor: .systemBlue,
                baseForegroundColor: .white,
                contentInsets: .init(top: 8, leading: 8, bottom: 8, trailing: 8),
                addShadow: true
            )
        } else {
            button.applyFilledStyle(
                title: title,
                baseBackgroundColor: .systemGray6,
                baseForegroundColor: .label,
                contentInsets: .init(top: 8, leading: 8, bottom: 8, trailing: 8),
                addShadow: false
            )
        }
    }

    func configure(name: String, email: String) {
        nameLabel.text = name
        emailLabel.text = email

        let comps = name.split(separator: " ")
        let initials = comps.prefix(2).compactMap { $0.first }.map(String.init).joined()
        initialsLabel.text = initials.uppercased()
    }

    @objc private func editTapped() { onEditProfile?() }
    @objc private func premiumTapped() { onGoPremium?() }
}
