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

    private let avatarContainer: UIView = {
        let v = UIView()
        return v
    }()

    private let avatarCircle: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCardElevated
        v.layer.masksToBounds = false
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowRadius = 18
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let initialsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 34, weight: .semibold)
        lbl.textAlignment = .center
        lbl.textColor = Palette.mgTextPrimary
        return lbl
    }()

    private let editBadge: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = Palette.mgAccent
        btn.tintColor = .black
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.layer.cornerRadius = 18
        btn.layer.shadowColor = Palette.mgAccent.cgColor
        btn.layer.shadowOpacity = 0.8
        btn.layer.shadowRadius = 10
        btn.layer.shadowOffset = .zero
        return btn
    }()

    private let tapLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to change"
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = Palette.mgAccent
        lbl.textAlignment = .center
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarCircle.layer.cornerRadius = avatarCircle.bounds.width / 2
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    private func setupUI() {
        contentView.addSubviews(avatarContainer)
        avatarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
        }

        avatarContainer.addSubviews(avatarCircle)
        avatarCircle.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.height.equalTo(120)
        }

        avatarCircle.addSubviews(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        avatarCircle.addSubviews(initialsLabel)
        initialsLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        avatarContainer.addSubviews(editBadge)
        editBadge.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.bottom.equalTo(avatarCircle.snp.bottom).offset(4)
            make.trailing.equalTo(avatarCircle.snp.trailing).offset(4)
        }
        editBadge.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)

        avatarContainer.addSubviews(tapLabel)
        tapLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarCircle.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTapped))
        avatarContainer.addGestureRecognizer(tap)
    }

    func configure(initialsFrom name: String,
                   avatarBase64: String?,
                   pickedImage: UIImage?) {

        if let pickedImage {
            avatarImageView.image = pickedImage
            avatarImageView.isHidden = false
            initialsLabel.isHidden = true
            return
        }

        if let base64 = avatarBase64,
           !base64.isEmpty,
           let data  = Data(base64Encoded: base64),
           let image = UIImage(data: data) {

            avatarImageView.image = image
            avatarImageView.isHidden = false
            initialsLabel.isHidden = true
            return
        }

        avatarImageView.image = nil
        avatarImageView.isHidden = true
        initialsLabel.isHidden = false

        let parts = name.split(separator: " ")
        let initials = parts
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
        initialsLabel.text = initials.uppercased()
    }

    @objc private func changeTapped() {
        onChangePhoto?()
    }
}
