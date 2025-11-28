//
//  ProfileStatView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class ProfileStatView: UIView {

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(title: String, value: String) {
        super.init(frame: .zero)
        setupUI(title: title, value: value)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI(title: String, value: String) {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true

        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        valueLabel.textAlignment = .center

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
}

// MARK: - ProfileRowView

final class ProfileRowView: UIControl {

    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(iconName: String, title: String) {
        super.init(frame: .zero)
        setupUI(iconName: iconName, title: title)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI(iconName: String, title: String) {
        backgroundColor = .clear

        // Icon container
        iconContainer.backgroundColor = UIColor.systemGray5
        iconContainer.layer.cornerRadius = 10
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .systemBlue
        iconContainer.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label

        chevronView.tintColor = .tertiaryLabel

        let hStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel, UIView(), chevronView])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 12

        addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }

        // separator
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.equalTo(hStack.snp.leading)
            make.trailing.equalTo(hStack.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
}
