//
//  TemplateSelectionView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit
import SnapKit

final class TemplateSelectionView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let previewImageView = UIImageView()
    private let actionButton = UIButton(type: .system)

    var onButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        configureInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .mgCard
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.borderWidth = 1
        layer.borderColor = UIColor.mgCardStroke.cgColor

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .mgTextPrimary

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .mgTextSecondary
        subtitleLabel.numberOfLines = 0

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.cornerRadius = 16
        previewImageView.layer.masksToBounds = true
        previewImageView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)

        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.setTitleColor(.mgTextPrimary, for: .normal)

        let bottomRow = UIStackView(arrangedSubviews: [previewImageView, actionButton])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 12

        let contentStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            bottomRow
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 8

        addSubview(contentStack)

        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        previewImageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }
    }

    private func setupActions() {
        actionButton.addTarget(
            self,
            action: #selector(handleButtonTap),
            for: .touchUpInside
        )
    }

    @objc private func handleButtonTap() {
        onButtonTapped?()
    }

    func configureInitialState(
        title: String = "Choose a Template",
        subtitle: String = "Pick a classic meme format. You can change it later."
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle("Select Template", for: .normal)
        previewImageView.image = nil
        previewImageView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)
    }

    func updateForSelectedTemplate(name: String, previewImage: UIImage?) {
        subtitleLabel.text = name
        actionButton.setTitle("Change Template", for: .normal)
        previewImageView.image = previewImage

        if previewImage != nil {
            previewImageView.backgroundColor = .clear
        } else {
            previewImageView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)
        }
    }
}
