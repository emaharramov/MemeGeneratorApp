//
//  VerifyEmailController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import UIKit
import SnapKit

final class VerifyEmailController: BaseController<VerifyEmailViewModel>, UITextFieldDelegate {

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        v.backgroundColor = .clear
        return v
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = Palette.mgTextPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Verify Email"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = Palette.mgTextSecondary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let stack: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 14
        st.alignment = .fill
        return st
    }()

    private let otpContainer = UIView()
    private let otpIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "number"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()

    private let otpField: UITextField = {
        let tf = UITextField.makeAuthField(
            placeholder: "6-digit code",
            keyboardType: .numberPad,
            isSecure: false,
            capitalization: .none
        )
        tf.textContentType = .oneTimeCode
        return tf
    }()

    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyFilledStyle(
            title: "Verify",
            systemImageName: nil,
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextPrimary,
            contentInsets: .init(top: 12, leading: 16, bottom: 12, trailing: 16),
            cornerStyle: .large,
            addShadow: true
        )
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    private let resendButton = UIButton.makeTextButton(
        title: "Resend code",
        titleColor: Palette.baseBackgroundColor,
        font: .systemFont(ofSize: 13, weight: .semibold),
        alignment: .left
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        configureNavigation(title: "Verify Email")

        subtitleLabel.text = "We sent a verification code to:\n\(viewModel.email)"

        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        contentView.addSubviews(titleLabel, subtitleLabel, card, verifyButton, resendButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        card.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        styleFieldContainer(otpContainer)
        stack.addArrangedSubview(otpContainer)
        otpContainer.snp.makeConstraints { $0.height.equalTo(52) }

        otpContainer.addSubviews(otpIcon, otpField)
        otpIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        otpField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalTo(otpIcon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
        }

        verifyButton.snp.makeConstraints {
            $0.top.equalTo(card.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(card)
            $0.height.equalTo(48)
        }

        resendButton.snp.makeConstraints {
            $0.top.equalTo(verifyButton.snp.bottom).offset(14)
            $0.leading.equalTo(verifyButton.snp.leading)
            $0.bottom.equalToSuperview().inset(24)
        }

        otpField.delegate = self
    }

    private func setupActions() {
        otpField.addTarget(self, action: #selector(onOtpChanged), for: .editingChanged)
        verifyButton.addTarget(self, action: #selector(onVerifyTap), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(onResendTap), for: .touchUpInside)
    }

    @objc private func onOtpChanged() {
        let raw = otpField.text ?? ""
        let digits = raw.filter(\.isNumber)
        if digits != raw { otpField.text = digits }

        if digits.count > 6 {
            otpField.text = String(digits.prefix(6))
        }

        let ok = (otpField.text ?? "").count == 6
        verifyButton.isEnabled = ok
        verifyButton.alpha = ok ? 1.0 : 0.5
    }

    @objc private func onVerifyTap() {
        view.endEditing(true)
        viewModel.verify(code: otpField.text ?? "")
    }

    @objc private func onResendTap() {
        view.endEditing(true)
        otpField.text = ""
        viewModel.resendCode()
    }

    private func styleFieldContainer(_ view: UIView) {
        view.backgroundColor = Palette.textFieldBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        view.layer.masksToBounds = true
    }
}
