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

    private let cardView = UIView()

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
        // CARD
        cardView.backgroundColor = .mgCard
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.mgCardStroke.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.35
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 18

        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }

        // Avatar
        avatarView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        avatarView.layer.cornerRadius = 32
        avatarView.clipsToBounds = true
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        avatarView.snp.makeConstraints { $0.width.height.equalTo(64) }

        initialsLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        initialsLabel.textAlignment = .center
        initialsLabel.textColor = .mgTextPrimary.withAlphaComponent(0.8)

        avatarView.addSubview(initialsLabel)
        initialsLabel.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Labels
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .mgTextPrimary

        emailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor = .mgTextSecondary

        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let topStack = UIStackView(arrangedSubviews: [avatarView, textStack])
        topStack.axis = .horizontal
        topStack.spacing = 14
        topStack.alignment = .center

        // Buttons
        configureButton(
            editButton,
            title: "Edit Profile",
            background: UIColor.white.withAlphaComponent(0.06),
            foreground: .mgTextPrimary,
            hasShadow: false
        )

        configureButton(
            premiumButton,
            title: "Go Premium",
            background: .mgAccent,
            foreground: .black,
            hasShadow: true
        )

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        premiumButton.addTarget(self, action: #selector(premiumTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [editButton, premiumButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 10
        buttonsStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [topStack, buttonsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16

        cardView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func configureButton(_ button: UIButton,
                                 title: String,
                                 background: UIColor,
                                 foreground: UIColor,
                                 hasShadow: Bool) {
        button.applyFilledStyle(
            title: title,
            baseBackgroundColor: background,
            baseForegroundColor: foreground,
            contentInsets: .init(top: 9, leading: 10, bottom: 9, trailing: 10),
            addShadow: hasShadow
        )
        button.layer.cornerRadius = 16
        button.clipsToBounds = false
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
