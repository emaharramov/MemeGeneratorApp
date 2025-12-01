//
//  EditProfileAvatarCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import UIKit
import SnapKit

final class EditProfileAvatarCell: UITableViewCell {

    static let reuseID = "EditProfileAvatarCell"

    var onChangePhoto: (() -> Void)?

    private let avatarContainer = UIView()
    private let avatarCircle = UIView()
    private let initialsLabel = UILabel()
    private let editBadge = UIButton(type: .system)
    private let tapLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(avatarContainer)
        avatarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
        }

        // Circle
        avatarCircle.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        avatarCircle.layer.cornerRadius = 60
        avatarCircle.layer.masksToBounds = false
        avatarCircle.layer.borderWidth = 1
        avatarCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        avatarCircle.layer.shadowColor = UIColor.black.cgColor
        avatarCircle.layer.shadowOpacity = 0.5
        avatarCircle.layer.shadowRadius = 18
        avatarCircle.layer.shadowOffset = CGSize(width: 0, height: 10)

        avatarContainer.addSubview(avatarCircle)
        avatarCircle.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalTo(120)
        }

        // initials
        initialsLabel.font = .systemFont(ofSize: 34, weight: .semibold)
        initialsLabel.textAlignment = .center
        initialsLabel.textColor = .mgTextPrimary

        avatarCircle.addSubview(initialsLabel)
        initialsLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }

        // Edit badge
        editBadge.backgroundColor = .mgAccent
        editBadge.tintColor = .black
        editBadge.setImage(UIImage(systemName: "pencil"), for: .normal)
        editBadge.layer.cornerRadius = 18
        editBadge.layer.shadowColor = UIColor.mgAccent.cgColor
        editBadge.layer.shadowOpacity = 0.8
        editBadge.layer.shadowRadius = 10
        editBadge.layer.shadowOffset = .zero
        editBadge.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)

        avatarContainer.addSubview(editBadge)
        editBadge.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.bottom.equalTo(avatarCircle.snp.bottom).offset(4)
            make.trailing.equalTo(avatarCircle.snp.trailing).offset(4)
        }

        // Tap label
        tapLabel.text = "Tap to change"
        tapLabel.font = .systemFont(ofSize: 13, weight: .medium)
        tapLabel.textColor = .mgAccent
        tapLabel.textAlignment = .center

        avatarContainer.addSubview(tapLabel)
        tapLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarCircle.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTapped))
        avatarContainer.addGestureRecognizer(tap)
    }

    func configure(initialsFrom name: String) {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
        initialsLabel.text = initials.uppercased()
    }

    @objc private func changeTapped() {
        onChangePhoto?()
    }
}
