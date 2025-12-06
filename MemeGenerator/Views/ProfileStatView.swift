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

import UIKit
import SnapKit

final class ProfileRowView: UIControl {

    var onTap: (() -> Void)?

    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(iconName: String, title: String) {
        super.init(frame: .zero)
        setupUI(iconName: iconName, title: title)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(iconName: String, title: String) {
        backgroundColor = .clear
        heightAnchor.constraint(equalToConstant: 56).isActive = true

        let bg = UIView()
        bg.backgroundColor = .systemBackground
        bg.addSubview(iconContainer)
        bg.addSubview(titleLabel)
        bg.addSubview(chevron)

        addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        iconContainer.layer.cornerRadius = 16

        iconContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .systemBlue
        iconContainer.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconContainer.snp.right).offset(12)
        }

        chevron.tintColor = .tertiaryLabel
        chevron.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
