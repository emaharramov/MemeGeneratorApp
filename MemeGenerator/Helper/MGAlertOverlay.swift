//
//  MGAlertOverlay.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit
import SnapKit

final class MGAlertOverlay: UIView {

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 22
        v.layer.masksToBounds = true
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = Palette.mgTextPrimary
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = Palette.mgTextSecondary
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 30)
        l.textAlignment = .center
        return l
    }()

    private let buttonsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 10
        return s
    }()

    private let secondaryButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    private let primaryButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    private var onPrimary: (() -> Void)?
    private var onSecondary: (() -> Void)?

    init(
        title: String,
        message: String,
        primaryTitle: String,
        secondaryTitle: String,
        emoji: String,
        onPrimary: (() -> Void)?,
        onSecondary: (() -> Void)?
    ) {
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.9)
        alpha = 0
        iconLabel.text = emoji
        titleLabel.text = title
        messageLabel.text = message
        configureButtons(primaryTitle: primaryTitle, secondaryTitle: secondaryTitle)
        setupLayout()
        animateIn()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButtons(primaryTitle: String, secondaryTitle: String) {
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        secondaryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        secondaryButton.setTitleColor(Palette.mgTextPrimary, for: .normal)
        secondaryButton.backgroundColor = Palette.mgLightBackground
        secondaryButton.layer.cornerRadius = 14
        secondaryButton.layer.masksToBounds = true

        primaryButton.setTitle(primaryTitle, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = Palette.mgAccent
        primaryButton.layer.cornerRadius = 14
        primaryButton.layer.masksToBounds = true

        secondaryButton.addTarget(self, action: #selector(handleSecondary), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(handlePrimary), for: .touchUpInside)
    }

    private func setupLayout() {
        addSubview(cardView)

        let textStack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.alignment = .center
        textStack.spacing = 8

        cardView.addSubview(textStack)
        cardView.addSubview(buttonsStack)

        buttonsStack.addArrangedSubview(secondaryButton)
        buttonsStack.addArrangedSubview(primaryButton)

        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        textStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        buttonsStack.snp.makeConstraints { make in
            make.top.equalTo(textStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }

    private func animateIn() {
        cardView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut]) {
            self.alpha = 1
            self.cardView.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseIn]) {
            self.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    @objc private func handlePrimary() {
        let action = onPrimary
        animateOut {
            action?()
        }
    }

    @objc private func handleSecondary() {
        let action = onSecondary
        animateOut {
            action?()
        }
    }

    static func show(
        on hostView: UIView,
        title: String,
        message: String,
        primaryTitle: String,
        secondaryTitle: String,
        emoji: String = "🤔",
        onPrimary: (() -> Void)?,
        onSecondary: (() -> Void)? = nil
    ) {
        let alert = MGAlertOverlay(
            title: title,
            message: message,
            primaryTitle: primaryTitle,
            secondaryTitle: secondaryTitle,
            emoji: emoji,
            onPrimary: onPrimary,
            onSecondary: onSecondary
        )
        hostView.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
