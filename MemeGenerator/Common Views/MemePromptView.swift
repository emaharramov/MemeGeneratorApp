//
//  MemePromptView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemePromptView: UIView {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .mgTextPrimary
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .mgTextSecondary
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let fieldTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .mgTextSecondary
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private let inputBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBg
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .textFieldTextColor
        tv.tintColor = .mgAccent
        tv.isScrollEnabled = false
        tv.keyboardAppearance = .dark
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textFieldTextColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var text: String {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
        }
    }

    init(
        title: String?,
        subtitle: String?,
        fieldTitle: String?,
        placeholder: String
    ) {
        super.init(frame: .zero)
        setupLayout()
        configure(
            title: title,
            subtitle: subtitle,
            fieldTitle: fieldTitle,
            placeholder: placeholder
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPlaceholderWithIcon(text: String, systemImageName: String) {
        guard let baseImage = UIImage(systemName: systemImageName) else {
            placeholderLabel.text = text
            updatePlaceholderVisibility()
            return
        }

        let color = placeholderLabel.textColor ?? .label

        let config = UIImage.SymbolConfiguration(
            pointSize: placeholderLabel.font.pointSize,
            weight: .medium
        )

        let configuredImage = baseImage
            .applyingSymbolConfiguration(config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)

        let attachment = NSTextAttachment()
        attachment.image = configuredImage
        let attributed = NSMutableAttributedString(
            string: text + " ",
            attributes: [
                .font: placeholderLabel.font as Any,
                .foregroundColor: color
            ]
        )

        attributed.append(NSAttributedString(attachment: attachment))

        placeholderLabel.attributedText = attributed
        updatePlaceholderVisibility()
    }

}

private extension MemePromptView {

    func setupLayout() {
        backgroundColor = .clear
        textView.delegate = self

        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let labelsStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            fieldTitleLabel
        ])
        labelsStack.axis = .vertical
        labelsStack.spacing = 6

        cardView.addSubview(labelsStack)
        cardView.addSubview(inputBackgroundView)

        labelsStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(labelsStack.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(70)
        }

        inputBackgroundView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        textView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
        }
    }

    func configure(
        title: String?,
        subtitle: String?,
        fieldTitle: String?,
        placeholder: String
    ) {
        configure(label: titleLabel, with: title)
        configure(label: subtitleLabel, with: subtitle)
        configure(label: fieldTitleLabel, with: fieldTitle)

        placeholderLabel.text = placeholder
        updatePlaceholderVisibility()
    }

    func configure(label: UILabel, with text: String?) {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        label.text = trimmed
        label.isHidden = trimmed.isEmpty
    }

    func updatePlaceholderVisibility() {
        let hasText = !textView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        placeholderLabel.isHidden = hasText
    }
}

extension MemePromptView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}
