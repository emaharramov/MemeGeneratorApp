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

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = false
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        return v
    }()

    private let iconBackground: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgAccentSoft
        v.layer.cornerRadius = 12
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Palette.mgAccent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = Palette.mgTextPrimary
        return lbl
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = Palette.mgTextSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

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
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16))
            make.height.equalTo(56)
        }

        iconBackground.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        iconBackground.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let stack = UIStackView(arrangedSubviews: [iconBackground, titleLabel, UIView(), chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        cardView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(
        iconName: String,
        title: String,
        isDestructive: Bool = false
    ) {
        iconView.image = UIImage(systemName: iconName)
        titleLabel.text = title

        if isDestructive {
            let red = UIColor.systemRed.withAlphaComponent(0.9)
            titleLabel.textColor = red
            iconView.tintColor = red
            chevron.tintColor = red.withAlphaComponent(0.9)
        } else {
            titleLabel.textColor = Palette.mgTextPrimary
            iconView.tintColor = Palette.mgAccent
            chevron.tintColor = Palette.mgTextSecondary
        }
    }
}
