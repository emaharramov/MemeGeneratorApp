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

    private let innerBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    private let placeholderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private let placeholderIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = Palette.mgAccent
        return iv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = Palette.mgAccent
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(placeholderText: String) {
        super.init(frame: .zero)
        setupUI()
        placeholderLabel.text = placeholderText
        updateState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubviews(innerBackground)
        innerBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(innerBackground.snp.width).multipliedBy(4.0 / 5.0)
        }

        innerBackground.addSubviews(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        innerBackground.addSubviews(placeholderStack)
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
            innerBackground.backgroundColor = Palette.cardBg
            imageView.isHidden = true
            imageView.image = nil
            placeholderStack.isHidden = false
        }
    }
}
