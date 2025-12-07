//
//  EmptyStateView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 07.12.25.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        isHidden = true
        backgroundColor = .clear

        titleLabel.textColor = Palette.mgTextPrimary
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.textColor = Palette.mgTextSecondary
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
