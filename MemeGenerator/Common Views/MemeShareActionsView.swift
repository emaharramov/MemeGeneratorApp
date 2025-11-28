//
//  MemeShareActionsView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemeShareActionsView: UIView {

    var onSave: (() -> Void)?
    var onShare: (() -> Void)?
    var onTryAgain: (() -> Void)?

    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        configure(button: saveButton,
                  title: "Save",
                  systemImage: "tray.and.arrow.down")

        configure(button: shareButton,
                  title: "Share",
                  systemImage: "square.and.arrow.up")

        configure(button: retryButton,
                  title: "Try Again",
                  systemImage: "arrow.clockwise")

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [saveButton, shareButton, retryButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(button: UIButton, title: String, systemImage: String) {
        var config = UIButton.Configuration.plain()

        // Icon + title
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        config.image = UIImage(systemName: systemImage, withConfiguration: symbolConfig)
        config.imagePlacement = .top
        config.imagePadding = 4

        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: 12.5, weight: .medium)
        config.attributedTitle = titleAttr
        config.baseForegroundColor = .label

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 6,
            bottom: 8,
            trailing: 6
        )

        button.configuration = config

        // Daha zərif kart stili
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0.6
        button.layer.borderColor = UIColor.systemGray4.withAlphaComponent(0.9).cgColor
    }

    @objc private func saveTapped() { onSave?() }
    @objc private func shareTapped() { onShare?() }
    @objc private func retryTapped() { onTryAgain?() }
}
