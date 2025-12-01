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

    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let subLabel = UILabel()
    private let badgeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth  = 1
        cardView.layer.borderColor  = UIColor.mgCardStroke.cgColor
        cardView.backgroundColor    = .mgCard

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .mgTextPrimary

        priceLabel.font = .systemFont(ofSize: 20, weight: .bold)
        priceLabel.textColor = .mgTextPrimary
        priceLabel.textAlignment = .right

        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .mgTextSecondary

        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
        badgeLabel.isHidden = true

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let topRow = UIStackView(arrangedSubviews: [leftStack, priceLabel])
        topRow.axis = .horizontal
        topRow.alignment = .firstBaseline
        topRow.spacing = 8

        let mainStack = UIStackView(arrangedSubviews: [topRow, badgeLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.alignment = .leading

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        badgeLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }

    func configure(title: String,
                   priceText: String,
                   subText: String,
                   badgeText: String?,
                   isSelected: Bool) {

        titleLabel.text = title
        priceLabel.text = priceText
        subLabel.text   = subText

        if let badgeText {
            badgeLabel.text = badgeText
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }

        // Selected state
        if isSelected {
            cardView.layer.borderColor = UIColor.mgAccent.cgColor
            cardView.backgroundColor   = UIColor.mgAccent.withAlphaComponent(0.18)
            if badgeText != nil {
                badgeLabel.backgroundColor = .mgAccent
            }
        } else {
            cardView.layer.borderColor = UIColor.mgCardStroke.cgColor
            cardView.backgroundColor   = .mgCard
            badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        }
    }
}
