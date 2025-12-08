//
//  ProfileStatCardView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileStatCardView: UIView {

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = Palette.mgCardElevated
        layer.cornerRadius = 18
        layer.masksToBounds = false
        layer.borderWidth = 1
        layer.borderColor = Palette.mgCardStroke.cgColor

        valueLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        valueLabel.textColor = Palette.mgTextPrimary

        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.textColor = Palette.mgTextSecondary

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading

        addSubviews(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
}
