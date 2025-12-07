//
//  ProfileStatsCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileStatsCell: UITableViewCell {

    static let reuseID = "ProfileStatsCell"

    private let memesCard = ProfileStatCardView()
    private let aiTemplateCard = ProfileStatCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [memesCard, aiTemplateCard])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 4, right: 16))
            make.height.equalTo(80)
        }
    }

    func configure(aiMemes: String, aiTemp: String) {
        memesCard.configure(value: aiMemes, title: "AI Memes")
        aiTemplateCard.configure(value: aiTemp, title: "AI + Template")
    }
}
