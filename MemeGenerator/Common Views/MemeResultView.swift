//
//  MemeResultView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemeResultView: UIView {

    private let containerView = UIView()
    private let placeholderStack = UIStackView()
    private let placeholderIcon = UIImageView()
    private let placeholderLabel = UILabel()
    private let imageView = UIImageView()

    var image: UIImage? {
        didSet { updateState() }
    }

    init(placeholderText: String) {
        super.init(frame: .zero)
        setupUI(placeholderText: placeholderText)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI(placeholderText: String) {
        backgroundColor = .clear

        containerView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.withAlphaComponent(0.7).cgColor

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isHidden = true

        placeholderIcon.image = UIImage(systemName: "sparkles")
        placeholderIcon.tintColor = .systemIndigo

        placeholderLabel.text = placeholderText
        placeholderLabel.font = .systemFont(ofSize: 14)
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0

        placeholderStack.axis = .vertical
        placeholderStack.alignment = .center
        placeholderStack.spacing = 8
        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(placeholderStack)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(240)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        placeholderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateState() {
        if let img = image {
            imageView.image = img
            imageView.isHidden = false
            placeholderStack.isHidden = true
        } else {
            imageView.image = nil
            imageView.isHidden = true
            placeholderStack.isHidden = false
        }
    }
}
