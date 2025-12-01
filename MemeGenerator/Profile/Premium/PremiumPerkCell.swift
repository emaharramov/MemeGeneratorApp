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
        cardView.backgroundColor = .mgCard
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = false
        cardView.layer.borderWidth  = 1
        cardView.layer.borderColor  = UIColor.mgCardStroke.cgColor

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .mgAccent
        iconView.snp.makeConstraints { $0.width.height.equalTo(22) }

        textLabelView.font = .systemFont(ofSize: 15, weight: .medium)
        textLabelView.textColor = .mgTextPrimary
        textLabelView.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconView, textLabelView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10

        contentView.addSubview(cardView)
        cardView.addSubview(stack)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
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
