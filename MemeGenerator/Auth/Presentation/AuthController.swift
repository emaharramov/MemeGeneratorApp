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

    // MARK: - State

    var mode: AuthMode {
        didSet { updateForMode() }
    }

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        return v
    }()

    private let contentView = UIView()

    // Header

    private let logoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "app_logo") // varsa
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .mgTextPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .mgTextSecondary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    // Form

    private let formCard = UIView()

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
        iv.tintColor = .mgTextSecondary
        return iv
    }()
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        tf.textColor = .mgTextPrimary
        tf.tintColor = .mgAccent
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        return tf
    }()

    private let usernameContainer = UIView()
    private let usernameIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person"))
        iv.tintColor = .mgTextSecondary
        return iv
    }()
    private let usernameField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        tf.textColor = .mgTextPrimary
        tf.tintColor = .mgAccent
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        return tf
    }()

    private let passwordContainer = UIView()
    private let passwordIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock"))
        iv.tintColor = .mgTextSecondary
        return iv
    }()
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        tf.textColor = .mgTextPrimary
        tf.tintColor = .mgAccent
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        return tf
    }()
    private let passwordVisibilityButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .mgTextSecondary
        btn.setImage(UIImage(systemName: "eye"), for: .normal)
        return btn
    }()

    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(.systemPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        return btn
    }()

    // Primary button

    private let primaryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        return btn
    }()

    // OR divider

    private let orLeftLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.mgCardStroke.withAlphaComponent(0.7)
        return v
    }()

    private let orRightLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.mgCardStroke.withAlphaComponent(0.7)
        return v
    }()

    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .mgTextSecondary
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

    // Google button

    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.mgCardStroke.cgColor
        return btn
    }()

    // Bottom section

    private let bottomTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .mgTextSecondary
        return label
    }()

    private let bottomActionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.systemPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return btn
    }()

    // MARK: - Init

    init(viewModel: AuthViewModel, mode: AuthMode) {
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mgBackground
        configureNavigation(title: "Auth")

        setupLayout()
        setupActions()
        updateForMode()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(logoView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formCard)
        contentView.addSubview(forgotPasswordButton)
        contentView.addSubview(primaryButton)
        contentView.addSubview(orStack)
        contentView.addSubview(googleButton)

        let bottomStack = UIStackView(arrangedSubviews: [bottomTextLabel, bottomActionButton])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 4
        bottomStack.alignment = .center

        contentView.addSubview(bottomStack)

        // Header constraints

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

        // Form card

        formCard.backgroundColor = .clear
        contentView.addSubview(formCard)
        formCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        formCard.addSubview(fieldsStack)
        fieldsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Field containers

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

        // Email layout

        emailContainer.addSubview(emailIcon)
        emailContainer.addSubview(emailField)

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

        // Username layout

        usernameContainer.addSubview(usernameIcon)
        usernameContainer.addSubview(usernameField)

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

        // Password layout

        passwordContainer.addSubview(passwordIcon)
        passwordContainer.addSubview(passwordField)
        passwordContainer.addSubview(passwordVisibilityButton)

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

        // Forgot password

        contentView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(formCard.snp.bottom).offset(8)
            make.trailing.equalTo(formCard.snp.trailing)
        }

        // Primary button

        primaryButton.applyFilledStyle(
            title: "",
            systemImageName: nil,
            baseBackgroundColor: .mgAccent,
            baseForegroundColor: .mgTextSecondary
        )

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(16)
            make.leading.trailing.equalTo(formCard)
            make.height.equalTo(48)
        }

        // OR divider

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

        // Google button

        configureGoogleButton()

        googleButton.snp.makeConstraints { make in
            make.top.equalTo(orStack.snp.bottom).offset(18)
            make.leading.trailing.equalTo(formCard)
            make.height.equalTo(46)
        }

        // Bottom

        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(googleButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - Styling helpers

    private func styleFieldContainer(_ view: UIView) {
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
        view.layer.masksToBounds = true
    }

    private func configureGoogleButton() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .mgTextPrimary
        config.background.backgroundColor = .mgCard
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.cornerStyle = .capsule

        let title = AttributedString(
            "", // mode-a görə sonra set olunacaq
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ])
        )
        config.attributedTitle = title

        let gImage = UIImage(named: "google_logo")
        config.image = gImage
        config.imagePadding = 8
        config.imagePlacement = .leading

        googleButton.configuration = config
    }

    // MARK: - Mode

    private func updateForMode() {
        switch mode {
        case .login:
            titleLabel.text = "Welcome Back!"
            subtitleLabel.text = "Log in to continue your meme journey."

            emailField.attributedPlaceholder = NSAttributedString(
                string: "Enter your email or username",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            usernameField.attributedPlaceholder = NSAttributedString(
                string: "Choose a username",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            passwordField.attributedPlaceholder = NSAttributedString(
                string: "Enter your password",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            usernameContainer.isHidden = true
            forgotPasswordButton.isHidden = false

            primaryButton.setTitle("Log In", for: .normal)

            googleButton.configuration?.attributedTitle = AttributedString(
                "Sign in with Google",
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
                ])
            )

            bottomTextLabel.text = "Don't have an account?"
            bottomActionButton.setTitle("Sign Up", for: .normal)

        case .register:
            titleLabel.text = "Create Your Account"
            subtitleLabel.text = "Join the meme community and start creating."

            emailField.attributedPlaceholder = NSAttributedString(
                string: "Enter your email",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            usernameField.attributedPlaceholder = NSAttributedString(
                string: "Choose a username",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            passwordField.attributedPlaceholder = NSAttributedString(
                string: "Create a password",
                attributes: [
                    .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7),
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium)
                ])

            usernameContainer.isHidden = false
            forgotPasswordButton.isHidden = true

            primaryButton.setTitle("Sign Up", for: .normal)

            googleButton.configuration?.attributedTitle = AttributedString(
                "Sign up with Google",
                attributes: AttributeContainer([
                    .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
                ])
            )

            bottomTextLabel.text = "Already have an account?"
            bottomActionButton.setTitle("Log In", for: .normal)
        }
    }

    // MARK: - Actions

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogleTapped), for: .touchUpInside)
        bottomActionButton.addTarget(self, action: #selector(handleToggleMode), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
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

    @objc private func handleGoogleTapped() {
        view.endEditing(true)
//        viewModel.signInWithGoogle(mode: mode)
    }

    @objc private func handleToggleMode() {
        mode = (mode == .login) ? .register : .login
//        viewModel.didChangeMode(to: mode)
    }

    @objc private func handleForgotPassword() {
//        viewModel.forgotPassword()
    }
}
