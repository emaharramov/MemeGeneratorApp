//
//  PremiumPlanCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import UIKit
import SnapKit

final class PremiumPlanCell: UITableViewCell {

    static let reuseID = "PremiumPlanCell"

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        view.backgroundColor = Palette.mgCard
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Palette.mgTextPrimary
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Palette.mgTextPrimary
        label.textAlignment = .right
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Palette.mgTextSecondary
        label.numberOfLines = 0
        return label
    }()

    private let badgeLabel: UILabel = {
        let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = Palette.mgTextPrimary
        label.textAlignment = .center
        label.backgroundColor = Palette.mgAccentSoft
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private lazy var leftStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private lazy var topRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [leftStack, priceLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 8
        return stack
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topRowStack, badgeLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .leading
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        badgeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }

    func configure(
        title: String,
        priceText: String,
        subText: String,
        badgeText: String?,
        isSelected: Bool
    ) {
        titleLabel.text = title
        priceLabel.text = priceText
        subLabel.text = subText

        if let badgeText {
            badgeLabel.text = badgeText
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }

        updateSelection(isSelected, hasBadge: badgeText != nil)
    }

    private func updateSelection(_ isSelected: Bool, hasBadge: Bool) {
        if isSelected {
            cardView.layer.borderColor = Palette.mgAccent.cgColor
            cardView.backgroundColor = Palette.mgAccentSoft
            priceLabel.textColor = Palette.mgAccent

            if hasBadge {
                badgeLabel.backgroundColor = Palette.mgAccent
                badgeLabel.textColor = Palette.mgTextPrimary
            }
        } else {
            cardView.layer.borderColor = Palette.mgCardStroke.cgColor
            cardView.backgroundColor = Palette.mgCard
            priceLabel.textColor = Palette.mgTextPrimary
            badgeLabel.backgroundColor = Palette.mgAccentSoft
            badgeLabel.textColor = Palette.mgTextPrimary
        }
    }
}
