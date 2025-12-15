//
//  ForgetPasswordController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import UIKit
import SnapKit
import Combine

protocol ForgetPasswordRouting: AnyObject {
    func didLogin()
}

final class ForgetPasswordController: BaseController<ForgetPasswordVM>, UITextFieldDelegate {

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

    private let badgeView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgAccentSoft
        v.layer.cornerRadius = 36
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        return v
    }()

    private let badgeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iv.tintColor = Palette.mgAccent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = Palette.mgTextPrimary
        l.numberOfLines = 0
        l.textAlignment = .left
        l.text = "Reset your password"
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = Palette.mgTextSecondary
        l.numberOfLines = 0
        l.textAlignment = .left
        l.text = "Enter the email you use for your meme account and we’ll send you a reset code."
        return l
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        v.layer.masksToBounds = true
        return v
    }()

    private let formStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 18
        s.alignment = .fill
        return s
    }()

    private let emailSection = UIView()
    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = Palette.mgPromptColor
        l.text = "Email address"
        return l
    }()

    private let emailContainer = UIView()
    private let emailIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()
    private let emailStatusIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = Palette.mgAccent
        iv.alpha = 0
        return iv
    }()
    private let emailField = UITextField.makeAuthField(
        placeholder: "name@example.com",
        keyboardType: .emailAddress,
        isSecure: false,
        capitalization: .none
    )
    private let emailHelper: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = Palette.mgTextSecondary
        l.numberOfLines = 0
        l.text = "We’ll send a reset code if this email is registered."
        return l
    }()

    private let otpSection = UIView()
    private let otpLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = Palette.mgPromptColor
        l.text = "OTP Code"
        return l
    }()
    private let otpContainer = UIView()
    private let otpIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = Palette.mgAccent
        iv.alpha = 0
        return iv
    }()
    private let otpField = UITextField.makeAuthField(
        placeholder: "000000",
        keyboardType: .numberPad,
        isSecure: false,
        capitalization: .none
    )
    private let otpHelper: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = Palette.mgTextSecondary
        l.numberOfLines = 0
        l.text = "Please enter 6 digits."
        l.alpha = 0
        return l
    }()

    private let passwordSection = UIView()
    private let passwordLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = Palette.mgPromptColor
        l.text = "New Password"
        return l
    }()
    private let passwordContainer = UIView()
    private let passwordIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()
    private let passwordField = UITextField.makeAuthField(
        placeholder: "••••••••",
        keyboardType: .default,
        isSecure: true,
        capitalization: .none
    )
    private let eyeButton = UIButton.makeIconButton(
        systemName: "eye.slash",
        pointSize: 16,
        weight: .medium,
        tintColor: Palette.mgTextSecondary,
        contentInsets: .init(top: 6, left: 6, bottom: 6, right: 6),
        backgroundColor: .clear,
        cornerRadius: 0
    )
    private let passwordHelper: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = Palette.mgTextSecondary
        l.numberOfLines = 0
        l.text = "Must be at least 8 characters."
        return l
    }()

    private let primaryButton: UIButton = {
        let b = UIButton(type: .system)
        b.applyFilledStyle(
            title: "Send OTP",
            systemImageName: nil,
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgBackground,
            contentInsets: .init(top: 12, leading: 16, bottom: 12, trailing: 16),
            cornerStyle: .large,
            addShadow: true
        )
        b.isEnabled = false
        b.alpha = 0.55
        return b
    }()

    private let backButton = UIButton.makeTextButton(
        title: "Back to login",
        titleColor: Palette.mgTextSecondary,
        font: .systemFont(ofSize: 15, weight: .semibold),
        alignment: .center
    )

    private var didRevealOtpUI = false
    private var didRevealPasswordUI = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mgBackground
        configureNavigation(title: "Reset Password")
        setupUI()
        applyPlaceholders()
        setupActions()
        setupDelegates()
        syncInputsToVM()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        contentView.addSubviews(badgeView, titleLabel, subtitleLabel, cardView, primaryButton, backButton)

        badgeView.addSubview(badgeIcon)

        badgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }
        badgeIcon.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(22) }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(badgeView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        cardView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(18)
        }

        cardView.addSubview(formStack)
        formStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(18) }

        buildEmailSection()
        buildOtpSection()
        buildPasswordSection()

        formStack.addArrangedSubview(emailSection)
        formStack.addArrangedSubview(otpSection)
        formStack.addArrangedSubview(passwordSection)

        otpSection.isHidden = true
        passwordSection.isHidden = true

        primaryButton.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(cardView)
            $0.height.equalTo(52)
        }

        backButton.snp.makeConstraints {
            $0.top.equalTo(primaryButton.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    private func styleFieldContainer(_ v: UIView) {
        v.backgroundColor = Palette.textFieldBackground
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        v.layer.masksToBounds = true
    }

    private func applyPrimaryStyle(enabled: Bool) {
        if enabled {
            primaryButton.alpha = 1.0
            primaryButton.setTitleColor(Palette.mgBackground, for: .normal)
            primaryButton.setTitleColor(Palette.mgBackground, for: .disabled)
        } else {
            primaryButton.alpha = 0.78
            primaryButton.setTitleColor(Palette.mgTextSecondary, for: .disabled)
            primaryButton.setTitleColor(Palette.mgTextSecondary, for: .normal)
        }
    }

    private func buildEmailSection() {
        emailSection.addSubviews(emailLabel, emailContainer, emailHelper)
        styleFieldContainer(emailContainer)

        emailLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        emailContainer.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        emailHelper.snp.makeConstraints {
            $0.top.equalTo(emailContainer.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emailContainer.addSubviews(emailIcon, emailField, emailStatusIcon)

        emailIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        emailStatusIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        emailField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.equalTo(emailIcon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    private func buildOtpSection() {
        otpSection.addSubviews(otpLabel, otpContainer, otpHelper)
        styleFieldContainer(otpContainer)

        otpLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        otpContainer.snp.makeConstraints {
            $0.top.equalTo(otpLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        otpHelper.snp.makeConstraints {
            $0.top.equalTo(otpContainer.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        otpContainer.addSubviews(otpIcon, otpField)

        otpIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        otpField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.equalTo(otpIcon.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    private func buildPasswordSection() {
        passwordSection.addSubviews(passwordLabel, passwordContainer, passwordHelper)
        styleFieldContainer(passwordContainer)

        passwordLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        passwordContainer.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        passwordHelper.snp.makeConstraints {
            $0.top.equalTo(passwordContainer.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        passwordContainer.addSubviews(passwordIcon, passwordField, eyeButton)

        passwordIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        eyeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        passwordField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.equalTo(passwordIcon.snp.trailing).offset(10)
            $0.trailing.equalTo(eyeButton.snp.leading).offset(-8)
        }
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(handlePrimary), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        emailField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        otpField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    private func setupDelegates() {
        otpField.delegate = self
    }

    @objc private func handlePrimary() {
        view.endEditing(true)
        syncInputsToVM()
        viewModel.handlePrimaryTapped()
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let name = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func textChanged() {
        syncInputsToVM()
    }

    private func syncInputsToVM() {
        viewModel.email = emailField.text ?? ""
        viewModel.otp = otpField.text ?? ""
        viewModel.newPassword = passwordField.text ?? ""
    }

    private func render(_ state: ForgetPasswordViewState) {
        if state.showOtpSection, otpSection.isHidden {
            revealOtpSectionUI()
        } else if !state.showOtpSection {
            otpSection.isHidden = true
        }

        if state.showPasswordSection, passwordSection.isHidden {
            revealPasswordSectionUI()
        } else if !state.showPasswordSection {
            passwordSection.isHidden = true
        }

        emailField.isEnabled = !state.emailLocked
        emailField.alpha = state.emailLocked ? 0.95 : 1.0

        emailIcon.alpha = state.showEmailStatusIcon ? 0 : 1
        emailStatusIcon.alpha = state.showEmailStatusIcon ? 1 : 0

        otpHelper.alpha = state.showOtpHelper ? 1 : 0
        otpIcon.alpha = state.showOtpCheckIcon ? 1 : 0

        passwordHelper.alpha = state.showPasswordHelper ? 1 : 0.0

        primaryButton.setTitle(state.primaryTitle, for: .normal)
        primaryButton.isEnabled = state.primaryEnabled
        applyPrimaryStyle(enabled: state.primaryEnabled)
    }

    private func revealOtpSectionUI() {
        guard !didRevealOtpUI else { return }
        didRevealOtpUI = true

        otpSection.isHidden = false
        otpSection.alpha = 0
        otpSection.transform = CGAffineTransform(translationX: 0, y: -6)

        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
            self.otpSection.alpha = 1
            self.otpSection.transform = .identity
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.otpField.becomeFirstResponder()
        }
    }

    private func revealPasswordSectionUI() {
        guard !didRevealPasswordUI else { return }
        didRevealPasswordUI = true

        passwordSection.isHidden = false
        passwordSection.alpha = 0
        passwordSection.transform = CGAffineTransform(translationX: 0, y: -6)

        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
            self.passwordSection.alpha = 1
            self.passwordSection.transform = .identity
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.passwordField.becomeFirstResponder()
        }
    }

    private func applyPlaceholders() {
        emailField.attributedPlaceholder = NSAttributedString(
            string: "name@example.com",
            attributes: [
                .foregroundColor: Palette.mgTextSecondary.withAlphaComponent(0.75),
                .font: UIFont.systemFont(ofSize: 15, weight: .medium)
            ]
        )

        otpField.attributedPlaceholder = NSAttributedString(
            string: "000000",
            attributes: [
                .foregroundColor: Palette.mgTextSecondary.withAlphaComponent(0.75),
                .font: UIFont.systemFont(ofSize: 15, weight: .medium)
            ]
        )
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField === otpField else { return true }
        return OTPInputFilter.allowChange(current: textField.text ?? "", range: range, replacement: string, maxLength: 6)
    }

    override func bindViewModel() {
        viewModel.$viewState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &viewModel.cancellables)

        render(viewModel.viewState)
    }
}

enum OTPInputFilter {
    static func allowChange(current: String, range: NSRange, replacement: String, maxLength: Int = 6) -> Bool {
        if !replacement.isEmpty,
           replacement.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return false
        }
        guard let r = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: r, with: replacement)
        return updated.count <= maxLength
    }
}
