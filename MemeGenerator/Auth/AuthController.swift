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

@MainActor
final class AuthController: BaseController<AuthViewModel> {

    // MARK: - Mode
    private var mode: AuthMode

    // MARK: - Slogan Animation
    private let sloganWords = ["creating", "making", "generating"]
    private var sloganIndex = 0
    private var sloganTimer: Timer?

    // MARK: - UI
    private let gradientLayer = CAGradientLayer()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Slogan Labels
    private let sloganLeftLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Join us to start"
        lbl.font = .systemFont(ofSize: 15)
        lbl.textAlignment = .right
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }()

    private let sloganWordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "creating"
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textAlignment = .center
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return lbl
    }()

    private let sloganRightLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "memes"
        lbl.font = .systemFont(ofSize: 15)
        lbl.textAlignment = .left
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }()

    private lazy var sloganStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            sloganLeftLabel,
            sloganWordLabel,
            sloganRightLabel
        ])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Fields
    private let emailField: FloatingTextField = {
        let field = FloatingTextField(title: "Email *", icon: UIImage(systemName: "envelope"))
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: FloatingTextField = {
        let field = FloatingTextField(title: "Password *", icon: nil)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    // Right eye button
    private let passwordToggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .lightGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Forget Password
    private let forgetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot password?", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .right
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Main Button
    private let mainButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = UIColor(red: 1, green: 0.97, blue: 0.7, alpha: 1)
        btn.layer.cornerRadius = 18
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 4
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.setTitleColor(.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Bottom toggle (register/login)
    private let toggleAuthButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init
    init(viewModel: AuthViewModel, mode: AuthMode = .login) {
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var shouldShowLogout: Bool { false }

    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func configureUI() {
        setupGradient()
        setupPasswordToggle()

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(sloganStack)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(forgetButton)
        view.addSubview(mainButton)
        view.addSubview(toggleAuthButton)

        mainButton.addTarget(self, action: #selector(onMainPressed), for: .touchUpInside)
        toggleAuthButton.addTarget(self, action: #selector(onToggleMode), for: .touchUpInside)

        updateModeUI(animated: false)
        startSloganAnimation()
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            // LOGO
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            // TITLE
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // SLOGAN
            sloganStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            sloganStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sloganStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            sloganStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),

            // EMAIL
            emailField.topAnchor.constraint(equalTo: sloganStack.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 55),

            // PASSWORD
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 18),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 55),

            // Forget password
            forgetButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 6),
            forgetButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),

            // MAIN BUTTON
            mainButton.topAnchor.constraint(equalTo: forgetButton.bottomAnchor, constant: 28),
            mainButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            mainButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: 55),

            // BOTTOM TOGGLE
            toggleAuthButton.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 18),
            toggleAuthButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Password toggle inside field
    private func setupPasswordToggle() {
        passwordField.addSubview(passwordToggleButton)

        NSLayoutConstraint.activate([
            passwordToggleButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor, constant: -12),
            passwordToggleButton.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            passwordToggleButton.widthAnchor.constraint(equalToConstant: 26),
            passwordToggleButton.heightAnchor.constraint(equalToConstant: 26)
        ])

        passwordField.textField.isSecureTextEntry = true
        passwordToggleButton.addTarget(self, action: #selector(onTogglePassword), for: .touchUpInside)
    }

    // MARK: - Background
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.47, blue: 0.7, alpha: 1).cgColor,
            UIColor(red: 0.34, green: 0.87, blue: 0.77, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Slogan Animation
    private func startSloganAnimation() {
        sloganTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { [weak self] _ in
            self?.animateSloganWord()
        }
    }

    private func animateSloganWord() {
        sloganIndex = (sloganIndex + 1) % sloganWords.count
        let newWord = sloganWords[sloganIndex]

        sloganWordLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        sloganWordLabel.alpha = 0
        sloganWordLabel.text = newWord

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.sloganWordLabel.transform = .identity
            self.sloganWordLabel.alpha = 1
        }
    }

    // MARK: - Actions
    @objc private func onTogglePassword() {
        let secure = passwordField.textField.isSecureTextEntry
        passwordField.textField.isSecureTextEntry = !secure
        passwordToggleButton.setImage(
            UIImage(systemName: secure ? "eye" : "eye.slash"),
            for: .normal
        )
    }

    @objc private func onMainPressed() {
        let email = emailField.textField.text?.lowercased() ?? ""
        let pass = passwordField.textField.text ?? ""
        
        switch mode {
        case .login:
            viewModel.login(email: email, password: pass)
        case .register:
            viewModel.register(email: email, password: pass)
        }
    }

    @objc private func onToggleMode() {
        mode = (mode == .login) ? .register : .login
        updateModeUI(animated: true)
    }

    private func updateModeUI(animated: Bool) {
        let block = {
            switch self.mode {
            case .login:
                self.titleLabel.text = "Welcome Back"
                self.mainButton.setTitle("Login", for: .normal)
                self.toggleAuthButton.setTitle("No account?  Register", for: .normal)
            case .register:
                self.titleLabel.text = "Meme Master"
                self.mainButton.setTitle("Register", for: .normal)
                self.toggleAuthButton.setTitle("Already a member?  Sign in", for: .normal)
            }
        }

        if animated {
            UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: block)
        } else { block() }
    }

    @MainActor
    deinit {
        sloganTimer?.invalidate()
    }
}
