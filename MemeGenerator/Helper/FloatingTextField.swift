//
//  FloatingTextField.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class FloatingTextField: UIView {

    private let titleLabel = UILabel()
    let textField = UITextField()
    private let iconView = UIImageView()

    private var isTitleLifted = false

    init(title: String, icon: UIImage?) {
        super.init(frame: .zero)
        setupUI(title: title, icon: icon)
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupUI(title: String, icon: UIImage?) {
        layer.cornerRadius = 18
        backgroundColor = UIColor(white: 0.97, alpha: 1)
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor

        // Title label
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .lightGray

        // TextField
        textField.borderStyle = .none
        textField.backgroundColor = .clear

        // Icon
        iconView.image = icon
        iconView.tintColor = .lightGray
        iconView.contentMode = .scaleAspectFit

        addSubview(titleLabel)
        addSubview(textField)
        addSubview(iconView)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 80),

            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: 18)
        ])
    }

    private func setupActions() {
        textField.addTarget(self, action: #selector(onFocus), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(onUnfocus), for: .editingDidEnd)
    }

    // MARK: - Animations
    @objc private func onFocus() {
        liftLabel()
    }

    @objc private func onUnfocus() {
        if textField.text?.isEmpty ?? true {
            lowerLabel()
        }
    }

    func liftLabel() {
        guard !isTitleLifted else { return }
        isTitleLifted = true

        UIView.animate(withDuration: 0.25) {
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -18).scaledBy(x: 0.9, y: 0.9)
            self.titleLabel.textColor = .darkGray
        }
    }

    func lowerLabel() {
        isTitleLifted = false

        UIView.animate(withDuration: 0.25) {
            self.titleLabel.transform = .identity
            self.titleLabel.textColor = .lightGray
        }
    }
}
