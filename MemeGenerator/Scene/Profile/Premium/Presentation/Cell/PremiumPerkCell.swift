//
//  PremiumPerkCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import UIKit
import SnapKit

final class PremiumPerkCell: UITableViewCell {

    static let reuseID = "PremiumPerkCell"

    private let cardView = UIView()
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let textLabelView = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        cardView.backgroundColor = Palette.mgCard
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth  = 1
        cardView.layer.borderColor  = Palette.mgCardStroke.cgColor

        iconContainer.backgroundColor = Palette.mgAccentSoft
        iconContainer.layer.cornerRadius = 18
        iconContainer.layer.masksToBounds = true

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Palette.mgAccent

        textLabelView.font = .systemFont(ofSize: 15, weight: .medium)
        textLabelView.textColor = Palette.mgTextPrimary
        textLabelView.numberOfLines = 0

        iconContainer.addSubviews(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        let stack = UIStackView(arrangedSubviews: [iconContainer, textLabelView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        contentView.addSubviews(cardView)
        cardView.addSubviews(stack)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }
    }

    func configure(iconName: String, text: String) {
        iconView.image = UIImage(systemName: iconName)
        textLabelView.text = text
    }
}
