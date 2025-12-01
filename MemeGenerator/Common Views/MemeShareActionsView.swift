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
    var onRegenerate: (() -> Void)?

    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private let regenerateButton = UIButton(type: .system)

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
        configure(button: regenerateButton,
                  title: "Reset",
                  systemImage: "arrow.counterclockwise")

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [saveButton, shareButton, retryButton, regenerateButton])
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

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        config.image = UIImage(systemName: systemImage, withConfiguration: symbolConfig)
        config.imagePlacement = .top
        config.imagePadding = 6

        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: 12.5, weight: .medium)
        config.attributedTitle = titleAttr
        config.baseForegroundColor = .mgTextSecondary

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 6,
            bottom: 10,
            trailing: 6
        )

        button.configuration = config

        button.backgroundColor = .mgCard
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mgCardStroke.cgColor
    }

    @objc private func saveTapped() { onSave?() }
    @objc private func shareTapped() { onShare?() }
    @objc private func retryTapped() { onTryAgain?() }
    @objc private func regenerateTapped() { onRegenerate?() }
}
