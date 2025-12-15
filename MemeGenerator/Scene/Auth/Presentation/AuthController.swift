//
//  AuthController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit
import SnapKit

enum AuthMode {
    case login
    case register
}

final class AuthController: BaseController<AuthViewModel> {

    private weak var router: AuthRouting?

    var mode: AuthMode {
        didSet { updateForMode() }
    }

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

    private let logoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "person.circle.fill")
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.tintColor = Palette.mgAccent
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = Palette.mgTextPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
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

    private let formCard: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let fieldsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        return stack
    }()

    private let emailContainer = UIView()
    private let emailIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()

    private let emailField = UITextField.makeAuthField(
        placeholder: "Email",
        keyboardType: .emailAddress,
        isSecure: false,
        capitalization: .none
    )

    private let usernameContainer = UIView()
    private let usernameIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()

    private let usernameField = UITextField.makeAuthField(
        placeholder: "Username",
        keyboardType: .default,
        isSecure: false,
        capitalization: .none
    )

    private let passwordField = UITextField.makeAuthField(
        placeholder: "Password",
        keyboardType: .default,
        isSecure: true,
        capitalization: .none
    )

    private let passwordContainer = UIView()
    private let passwordIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock"))
        iv.tintColor = Palette.mgTextSecondary
        return iv
    }()

    private let passwordVisibilityButton = UIButton.makeIconButton(
        systemName: "eye",
        pointSize: 16,
        weight: .medium,
        tintColor: Palette.mgTextSecondary,
        contentInsets: .init(top: 6, left: 6, bottom: 6, right: 6),
        backgroundColor: .clear,
        cornerRadius: 0
    )

    private let forgotPasswordButton = UIButton.makeTextButton(
        title: "Forgot Password?",
        titleColor: Palette.baseBackgroundColor,
        font: .systemFont(ofSize: 13, weight: .semibold),
        alignment: .right
    )

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyFilledStyle(
            title: "",
            systemImageName: nil,
            baseBackgroundColor: Palette.mgAccent,
            baseForegroundColor: Palette.mgTextPrimary,
            contentInsets: .init(top: 12, leading: 16, bottom: 12, trailing: 16),
            cornerStyle: .large,
            addShadow: true
        )
        return button
    }()

    private let orLeftLine: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCardStroke.withAlphaComponent(0.7)
        return v
    }()

    private let orRightLine: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCardStroke.withAlphaComponent(0.7)
        return v
    }()

    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = Palette.mgTextSecondary
        label.textAlignment = .center
        return label
    }()

    private let orStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private let bottomTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Palette.mgTextSecondary
        return label
    }()

    private let bottomActionButton = UIButton.makeTextButton(
        title: "",
        titleColor: Palette.baseBackgroundColor,
        font: .systemFont(ofSize: 14, weight: .semibold),
        alignment: .center
    )

    init(viewModel: AuthViewModel, mode: AuthMode, router: AuthRouting) {
        self.router = router
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.mgBackground
        configureNavigation(title: "Auth")

        setupLayout()
        setupActions()
        updateForMode()
    }

    private func setupLayout() {
        view.addSubviews(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubviews(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubviews(logoView,titleLabel,subtitleLabel,formCard,forgotPasswordButton,primaryButton,orStack)

        let bottomStack = UIStackView(arrangedSubviews: [bottomTextLabel, bottomActionButton])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 4
        bottomStack.alignment = .center

        contentView.addSubviews(bottomStack)

        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        formCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        formCard.addSubviews(fieldsStack)
        fieldsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        styleFieldContainer(emailContainer)
        styleFieldContainer(usernameContainer)
        styleFieldContainer(passwordContainer)

        fieldsStack.addArrangedSubview(emailContainer)
        fieldsStack.addArrangedSubview(usernameContainer)
        fieldsStack.addArrangedSubview(passwordContainer)

        emailContainer.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        usernameContainer.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        passwordContainer.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        emailContainer.addSubviews(emailIcon)
        emailContainer.addSubviews(emailField)

        emailIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        emailField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(emailIcon.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(16)
        }

        usernameContainer.addSubviews(usernameIcon)
        usernameContainer.addSubviews(usernameField)

        usernameIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        usernameField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(usernameIcon.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(16)
        }

        passwordContainer.addSubviews(passwordIcon)
        passwordContainer.addSubviews(passwordField)
        passwordContainer.addSubviews(passwordVisibilityButton)

        passwordIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        passwordVisibilityButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }

        passwordField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(passwordIcon.snp.trailing).offset(10)
            make.trailing.equalTo(passwordVisibilityButton.snp.leading).offset(-8)
        }

        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(formCard.snp.bottom).offset(8)
            make.trailing.equalTo(formCard.snp.trailing)
        }

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(16)
            make.leading.trailing.equalTo(formCard)
            make.height.equalTo(48)
        }

        orStack.addArrangedSubview(orLeftLine)
        orStack.addArrangedSubview(orLabel)
        orStack.addArrangedSubview(orRightLine)

        orLeftLine.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        orRightLine.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        orStack.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(formCard)
            make.height.equalTo(20)
        }

        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(orStack.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
    }

    private func styleFieldContainer(_ view: UIView) {
        view.backgroundColor = Palette.textFieldBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        view.layer.masksToBounds = true
    }

    private func updateForMode() {
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Palette.mgTextSecondary.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]

        switch mode {
        case .login:
            titleLabel.text = "Welcome Back!"
            subtitleLabel.text = "Log in to continue your meme journey."

            emailField.attributedPlaceholder = NSAttributedString(
                string: "Enter your email or username",
                attributes: placeholderAttributes
            )

            usernameField.attributedPlaceholder = NSAttributedString(
                string: "Choose a username",
                attributes: placeholderAttributes
            )

            passwordField.attributedPlaceholder = NSAttributedString(
                string: "Enter your password",
                attributes: placeholderAttributes
            )

            usernameContainer.isHidden = true
            forgotPasswordButton.isHidden = false

            primaryButton.setTitle("Log In", for: .normal)
            bottomTextLabel.text = "Don't have an account?"
            bottomActionButton.setTitle("Sign Up", for: .normal)

        case .register:
            titleLabel.text = "Create Your Account"
            subtitleLabel.text = "Join the meme community and start creating."

            emailField.attributedPlaceholder = NSAttributedString(
                string: "Enter your email",
                attributes: placeholderAttributes
            )

            usernameField.attributedPlaceholder = NSAttributedString(
                string: "Choose a username",
                attributes: placeholderAttributes
            )

            passwordField.attributedPlaceholder = NSAttributedString(
                string: "Create a password",
                attributes: placeholderAttributes
            )

            usernameContainer.isHidden = false
            forgotPasswordButton.isHidden = true

            primaryButton.setTitle("Sign Up", for: .normal)
            bottomTextLabel.text = "Already have an account?"
            bottomActionButton.setTitle("Log In", for: .normal)
        }
        updatePrimaryButtonState()
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        bottomActionButton.addTarget(self, action: #selector(handleToggleMode), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)

        emailField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
            usernameField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
            passwordField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        updatePrimaryButtonState()
    }

    @objc private func handleEditingChanged() {
        updatePrimaryButtonState()
    }

    private func updatePrimaryButtonState() {
        let email = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let username = (usernameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text ?? ""

        let emailOk = isValidEmail(email)

        let enabled: Bool
        switch mode {
        case .login:
            enabled = emailOk && password.count >= 8

        case .register:
            enabled = emailOk && !username.isEmpty && isStrongPasswordForRegister(password)
        }

        applyPrimaryButton(enabled: enabled)
    }

    private func applyPrimaryButton(enabled: Bool) {
        primaryButton.isEnabled = enabled
        primaryButton.isUserInteractionEnabled = enabled

        // Sadə disabled görünüş
        UIView.animate(withDuration: 0.15) {
            self.primaryButton.alpha = enabled ? 1.0 : 0.45
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        guard !value.isEmpty else { return false }
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", emailRegex).evaluate(with: value)
    }

    private func isStrongPasswordForRegister(_ value: String) -> Bool {
        guard value.count >= 8 else { return false }
        return true
    }

    @objc private func handlePrimaryTapped() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let username = usernameField.text ?? ""

        view.endEditing(true)

        switch mode {
        case .login:
            viewModel.login(email: email, password: password)
        case .register:
            viewModel.register(email: email, username: username, password: password)
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let name = passwordField.isSecureTextEntry ? "eye" : "eye.slash"
        passwordVisibilityButton.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func handleToggleMode() {
        mode = (mode == .login) ? .register : .login
        updatePrimaryButtonState()
    }

    @objc private func handleForgotPassword() {
        router?.showForgotPassword()
    }
}
