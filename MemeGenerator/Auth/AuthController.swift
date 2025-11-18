//
//  AuthController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class AuthController: BaseController<AuthViewModel> {

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return btn
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 16
        return s
    }()

    // MARK: - BaseController Overrides

    override func configureUI() {
        navigationItem.title = "Login"

        [titleLabel, emailTextField, passwordTextField, loginButton].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)

        loginButton.addTarget(self, action: #selector(onLoginPressed), for: .touchUpInside)
    }

    override func configureConstraints() {
        [stack, titleLabel, emailTextField, passwordTextField, loginButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    override func bindViewModel() {
        // Hook up loading / error state here if desired using Combine
        // Example (pseudocode):
        // viewModel.$isLoading
        //     .receive(on: RunLoop.main)
        //     .sink { [weak self] loading in self?.loginButton.isEnabled = !loading }
        //     .store(in: &viewModel.cancellables)
    }

    // MARK: - Actions

    @objc private func onLoginPressed() {
        let email = emailTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        viewModel.login(email: email, password: pass)
    }
}
