//
//  MemePromptView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemePromptView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let fieldTitleLabel = UILabel()
    private let inputBackgroundView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()

    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
        }
    }

    init(title: String?,
         subtitle: String?,
         fieldTitle: String?,
         placeholder: String) {
        super.init(frame: .zero)
        setupUI(title: title, subtitle: subtitle, fieldTitle: fieldTitle, placeholder: placeholder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(title: String?,
                         subtitle: String?,
                         fieldTitle: String?,
                         placeholder: String) {

        backgroundColor = .clear

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = (title?.isEmpty ?? true)

        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = (subtitle?.isEmpty ?? true)

        fieldTitleLabel.text = fieldTitle
        fieldTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fieldTitleLabel.textColor = .label
        fieldTitleLabel.numberOfLines = 1
        fieldTitleLabel.isHidden = (fieldTitle?.isEmpty ?? true)

        inputBackgroundView.backgroundColor = .systemBackground
        inputBackgroundView.layer.cornerRadius = 16
        inputBackgroundView.layer.borderWidth = 1
        inputBackgroundView.layer.borderColor = UIColor.systemGray4.withAlphaComponent(0.7).cgColor

        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        textView.delegate = self
        textView.isScrollEnabled = false

        placeholderLabel.text = placeholder
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, fieldTitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.alignment = .fill

        addSubview(labelsStack)
        addSubview(inputBackgroundView)
        inputBackgroundView.addSubview(textView)
        textView.addSubview(placeholderLabel)

        labelsStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        inputBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(labelsStack.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(90)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(textView.textContainerInset.top)
            make.leading.equalToSuperview().inset(textView.textContainerInset.left + 2)
            make.trailing.lessThanOrEqualToSuperview().inset(textView.textContainerInset.right)
        }

        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }
}

extension MemePromptView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) { updatePlaceholderVisibility() }
    func textViewDidBeginEditing(_ textView: UITextView) { updatePlaceholderVisibility() }
    func textViewDidEndEditing(_ textView: UITextView) { updatePlaceholderVisibility() }
}
