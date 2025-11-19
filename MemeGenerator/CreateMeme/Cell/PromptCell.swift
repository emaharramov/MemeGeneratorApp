//
//  PromptCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class PromptCell: UICollectionViewCell {

    static let id = "PromptCell"

    let textView = UITextView()
    private let placeholderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        textView.delegate = self

        contentView.addSubview(textView)
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Placeholder setup
        placeholderLabel.text = "Write your meme prompt..."
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false

        textView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(textView.textContainerInset.top)
            make.leading.equalToSuperview().inset(textView.textContainerInset.left + 2)
            make.trailing.lessThanOrEqualToSuperview().inset(textView.textContainerInset.right)
        }

        updatePlaceholderVisibility()
    }

    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
        }
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UITextViewDelegate

extension PromptCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}
