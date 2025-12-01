//
//  MemeResultView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemeResultView: UIView {

    var image: UIImage? {
        didSet { updateState() }
    }

    private let innerBackground = UIView()
    private let imageView = UIImageView()
    private let placeholderStack = UIStackView()
    private let placeholderIcon = UIImageView()
    private let placeholderLabel = UILabel()

    init(placeholderText: String) {
        super.init(frame: .zero)
        setupUI(placeholderText: placeholderText)
        updateState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(placeholderText: String) {
        backgroundColor = .clear

        innerBackground.layer.cornerRadius = 18
        innerBackground.layer.masksToBounds = true

        addSubview(innerBackground)
        innerBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(innerBackground.snp.width).multipliedBy(4.0/5.0)
        }

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        innerBackground.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderIcon.image = UIImage(systemName: "sparkles")
        placeholderIcon.tintColor = .mgAccent

        placeholderLabel.text = placeholderText
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = .mgAccent
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0

        placeholderStack.axis = .vertical
        placeholderStack.alignment = .center
        placeholderStack.spacing = 8
        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        innerBackground.addSubview(placeholderStack)
        placeholderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
        }
    }

    private func updateState() {
        if let img = image {
            innerBackground.backgroundColor = .clear
            imageView.isHidden = false
            imageView.image = img
            placeholderStack.isHidden = true
        } else {
            innerBackground.backgroundColor = .cardBg
            imageView.isHidden = true
            imageView.image = nil
            placeholderStack.isHidden = false
        }
    }
}
