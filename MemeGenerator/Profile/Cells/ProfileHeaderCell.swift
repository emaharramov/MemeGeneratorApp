//
//  ProfileHeaderCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileHeaderCell: UITableViewCell {

    // MARK: - Public

    static let reuseID = "ProfileHeaderCell"

    var onEditProfile: (() -> Void)?
    var onGoPremium: (() -> Void)?

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .mgCard
        v.layer.cornerRadius = 22
        v.layer.masksToBounds = false
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.mgCardStroke.cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 18
        return v
    }()

    private let avatarContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.image = UIImage(systemName: "person.fill")
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .mgTextPrimary
        lbl.numberOfLines = 1
        return lbl
    }()

    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .mgTextSecondary
        lbl.numberOfLines = 1
        return lbl
    }()

    private let editButton = UIButton(type: .system)
    private let premiumButton = UIButton(type: .system)

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        // dinamik dairə
        avatarContainerView.layer.cornerRadius = avatarContainerView.bounds.width / 2
        avatarImageView.layer.cornerRadius     = avatarImageView.bounds.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text  = nil
        emailLabel.text = nil
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.contentMode = .scaleAspectFit
    }

    // MARK: - Setup

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            )
        }

        avatarContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }

        avatarContainerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let topStack = UIStackView(arrangedSubviews: [avatarContainerView, textStack])
        topStack.axis = .horizontal
        topStack.alignment = .center
        topStack.spacing = 14

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
            background: .mgBackground,
            foreground: .mgTextPrimary,
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

    // MARK: - Public configure

    /// `avatarBase64` – backend-dən gələn base64 şəkil string-i
    func configure(name: String,
                   email: String,
                   isPremium: Bool,
                   avatarBase64: String? = nil) {
        nameLabel.text = name
        emailLabel.text = email

        updateAvatar(with: avatarBase64)

        configureButton(
            premiumButton,
            title: isPremium ? "Subscription" : "Go Premium",
            background: .mgBackground,
            foreground: .mgTextPrimary,
            hasShadow: true
        )
    }

    // MARK: - Avatar

    private func updateAvatar(with base64: String?) {
        guard
            let base64,
            !base64.isEmpty,
            let data  = Data(base64Encoded: base64),
            let image = UIImage(data: data)
        else {
            avatarImageView.image = UIImage(systemName: "person.fill")
            avatarImageView.contentMode = .scaleAspectFit
            return
        }

        avatarImageView.image = image
        avatarImageView.contentMode = .scaleAspectFill
    }

    // MARK: - Actions

    @objc private func editTapped() {
        onEditProfile?()
    }

    @objc private func premiumTapped() {
        onGoPremium?()
    }
}
