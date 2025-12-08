//
//  TemplateSelectionView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit
import SnapKit

final class TemplateSelectionView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = Palette.mgTextPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = Palette.mgTextSecondary
        label.numberOfLines = 0
        return label
    }()

    private let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.backgroundColor = Palette.mgLightBackground
        return iv
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(Palette.mgTextPrimary, for: .normal)
        return button
    }()

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
        backgroundColor = Palette.mgCard
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.borderWidth = 1
        layer.borderColor = Palette.mgCardStroke.cgColor

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

        addSubviews(contentStack)

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
        previewImageView.backgroundColor = Palette.mgLightBackground
    }

    func updateForSelectedTemplate(name: String, previewImage: UIImage?) {
        subtitleLabel.text = name
        actionButton.setTitle("Change Template", for: .normal)
        previewImageView.image = previewImage

        if previewImage != nil {
            previewImageView.backgroundColor = .clear
        } else {
            previewImageView.backgroundColor = Palette.mgLightBackground
        }
    }
}
