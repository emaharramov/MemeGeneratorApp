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

@MainActor
final class AuthController: BaseController<AuthViewModel> {

    private var mode: AuthMode

    private let sloganWords = ["creating", "making", "generating"]
    private var sloganIndex = 0
    private var sloganTimer: Timer?

    private let gradientLayer = CAGradientLayer()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        return lbl
    }()

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
        return sv
    }()

    private let emailField: FloatingTextField = {
        let field = FloatingTextField(title: "Email *", icon: UIImage(systemName: "envelope"))
        return field
    }()

    private let passwordField: FloatingTextField = {
        let field = FloatingTextField(title: "Password *", icon: nil)
        return field
    }()

    private let passwordToggleButton = UIButton.makeIconButton(
        systemName: "eye.slash",
        tintColor: .lightGray,
        contentInsets: .zero
    )

    private let forgetButton = UIButton.makeTextButton(
        title: "Forgot password?",
        titleColor: .darkGray,
        font: .systemFont(ofSize: 14),
        alignment: .right
    )

    private let mainButton: UIButton = UIButton.makeFilledAction(
        title: "Login",
        baseBackgroundColor: UIColor(red: 1, green: 0.97, blue: 0.7, alpha: 1),
        baseForegroundColor: .black
    )

    private let toggleAuthButton = UIButton.makeTextButton(
        title: "",
        titleColor: .darkGray,
        font: .systemFont(ofSize: 15),
        alignment: .center
    )
    
    init(viewModel: AuthViewModel, mode: AuthMode = .login) {
        self.mode = mode
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func configureUI() {
        setupGradient()
        setupPasswordToggle()
        
        [
            logoImageView,
            titleLabel,
            sloganStack,
            emailField,
            passwordField,
            forgetButton,
            mainButton,
            toggleAuthButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }


        mainButton.addTarget(self, action: #selector(onMainPressed), for: .touchUpInside)
        toggleAuthButton.addTarget(self, action: #selector(onToggleMode), for: .touchUpInside)

        updateModeUI(animated: false)
        startSloganAnimation()
    }

    override func configureConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(100)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }

        sloganStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(view).offset(40)
            $0.trailing.lessThanOrEqualTo(view).offset(-40)
        }

        emailField.snp.makeConstraints {
            $0.top.equalTo(sloganStack.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(55)
        }

        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(18)
            $0.leading.trailing.height.equalTo(emailField)
        }

        forgetButton.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(6)
            $0.trailing.equalTo(passwordField.snp.trailing)
        }

        mainButton.snp.makeConstraints {
            $0.top.equalTo(forgetButton.snp.bottom).offset(28)
            $0.leading.trailing.equalTo(emailField)
            $0.height.equalTo(55)
        }

        toggleAuthButton.snp.makeConstraints {
            $0.top.equalTo(mainButton.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupPasswordToggle() {
        passwordField.addSubview(passwordToggleButton)

        passwordToggleButton.snp.makeConstraints {
            $0.trailing.equalTo(passwordField.snp.trailing).offset(-12)
            $0.centerY.equalTo(passwordField.snp.centerY)
            $0.width.height.equalTo(26)
        }

        passwordField.textField.isSecureTextEntry = true

        passwordToggleButton.addTarget(self,
                                       action: #selector(onTogglePassword),
                                       for: .touchUpInside)
    }


    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.47, blue: 0.7, alpha: 1).cgColor,
            UIColor(red: 0.34, green: 0.87, blue: 0.77, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

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
