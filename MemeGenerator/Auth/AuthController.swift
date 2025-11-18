//
//  AuthController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

enum AuthMode {
    case login
    case register
}

final class AuthController: BaseController<AuthViewModel> {

    // MARK: - Mode
    private var mode: AuthMode

    private var isLoginMode: Bool {
        mode == .login
    }

    // MARK: - Init
    init(viewModel: AuthViewModel, mode: AuthMode = .register) {
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - UI Elements

    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let actionButton = UIButton(type: .system)
    private let toggleButton = UIButton(type: .system)
    private let stack = UIStackView()

    // MARK: - BaseController Overrides

    override var shouldShowLogout: Bool { false }   // Hide logout in Auth screen

    override func configureUI() {
        setupStyles()
        updateUI(animated: false)

        stack.axis = .vertical
        stack.spacing = 20

        [emojiLabel, titleLabel, emailField, passwordField, actionButton, toggleButton]
            .forEach { stack.addArrangedSubview($0) }

        view.addSubview(stack)

        actionButton.addTarget(self, action: #selector(onMainPressed), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(onToggle), for: .touchUpInside)
    }

    override func configureConstraints() {
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            actionButton.heightAnchor.constraint(equalToConstant: 55),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Setup Styles

    private func setupStyles() {
        titleLabel.font = .systemFont(ofSize: 30, weight: .heavy)
        titleLabel.textAlignment = .center

        emojiLabel.font = .systemFont(ofSize: 46)
        emojiLabel.textAlignment = .center

        emailField.placeholder = "Email"
        emailField.borderStyle = .roundedRect
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none

        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true

        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = 12

        toggleButton.setTitleColor(.systemBlue, for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 15)
    }

    // MARK: - UI Update

    private func updateUI(animated: Bool = true) {
        let changes = {
            if self.isLoginMode {
                self.titleLabel.text = "Welcome Back"
                self.emojiLabel.text = "👋"
                self.actionButton.setTitle("Login", for: .normal)
                self.actionButton.backgroundColor = .systemBlue
                self.passwordField.placeholder = "Password"
                self.toggleButton.setTitle("Don't have an account? Register", for: .normal)
                self.navigationItem.title = "Login"
            } else {
                self.titleLabel.text = "Create Account"
                self.emojiLabel.text = "😄"
                self.actionButton.setTitle("Sign Up", for: .normal)
                self.actionButton.backgroundColor = .systemGreen
                self.passwordField.placeholder = "Create a password"
                self.toggleButton.setTitle("Already have an account? Login", for: .normal)
                self.navigationItem.title = "Register"
            }
        }

        if animated {
            UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve, animations: changes)
        } else {
            changes()
        }
    }

    // MARK: - Actions

    @objc private func onMainPressed() {
        let email = emailField.text ?? ""
        let pass = passwordField.text ?? ""

        if isLoginMode {
            viewModel.login(email: email, password: pass)
        } else {
            viewModel.register(email: email, password: pass)
        }
    }

    @objc private func onToggle() {
        mode = isLoginMode ? .register : .login

        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: []) {
            self.emojiLabel.transform = self.isLoginMode
                ? CGAffineTransform(rotationAngle: .pi / 8)
                : .identity
        }

        updateUI()
    }
}
