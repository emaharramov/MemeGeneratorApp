//
//  FloatingTextField.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

//import UIKit
//import SnapKit
//
//final class FloatingTextField: UIView {
//
//    private let titleLabel = UILabel()
//    let textField = UITextField()
//    private let iconView = UIImageView()
//
//    private var isTitleLifted = false
//
//    init(title: String, icon: UIImage?) {
//        super.init(frame: .zero)
//        setupUI(title: title, icon: icon)
//        setupConstraints()
//        setupActions()
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//    private func setupUI(title: String, icon: UIImage?) {
//        layer.cornerRadius = 18
//        backgroundColor = UIColor(white: 0.97, alpha: 1)
//        layer.borderWidth = 1
//        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
//
//        titleLabel.text = title
//        titleLabel.font = .systemFont(ofSize: 15)
//        titleLabel.textColor = .lightGray
//
//        textField.borderStyle = .none
//        textField.backgroundColor = .clear
//
//        iconView.image = icon
//        iconView.tintColor = .lightGray
//        iconView.contentMode = .scaleAspectFit
//
//        addSubview(titleLabel)
//        addSubview(textField)
//        addSubview(iconView)
//    }
//
//    private func setupConstraints() {
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//
//        snp.makeConstraints { make in
//            make.height.equalTo(80)
//        }
//
//        iconView.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().inset(16)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(22)
//            make.height.equalTo(22)
//        }
//
//        textField.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(16)
//            make.trailing.equalTo(iconView.snp.leading).offset(-10)
//            make.top.equalToSuperview().offset(18)
//            make.bottom.equalToSuperview().inset(8)
//        }
//
//        titleLabel.snp.makeConstraints { make in
//            make.leading.equalTo(textField.snp.leading)
//            make.bottom.equalTo(textField.snp.top).offset(18)
//        }
//
//    }
//
//    private func setupActions() {
//        textField.addTarget(self, action: #selector(onFocus), for: .editingDidBegin)
//        textField.addTarget(self, action: #selector(onUnfocus), for: .editingDidEnd)
//    }
//
//    @objc private func onFocus() {
//        liftLabel()
//    }
//
//    @objc private func onUnfocus() {
//        if textField.text?.isEmpty ?? true {
//            lowerLabel()
//        }
//    }
//
//    func liftLabel() {
//        guard !isTitleLifted else { return }
//        isTitleLifted = true
//
//        UIView.animate(withDuration: 0.25) {
//            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -18).scaledBy(x: 0.9, y: 0.9)
//            self.titleLabel.textColor = .darkGray
//        }
//    }
//
//    func lowerLabel() {
//        isTitleLifted = false
//
//        UIView.animate(withDuration: 0.25) {
//            self.titleLabel.transform = .identity
//            self.titleLabel.textColor = .lightGray
//        }
//    }
//}
