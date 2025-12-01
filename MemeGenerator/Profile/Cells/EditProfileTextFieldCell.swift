//
//  EditProfileTextFieldCell.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import UIKit
import SnapKit

final class EditProfileTextFieldCell: UITableViewCell {

    static let reuseID = "EditProfileTextFieldCell"

    let textField = UITextField()

    private let titleLabel = UILabel()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .mgTextSecondary

        containerView.backgroundColor = .mgCard
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = false
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.mgCardStroke.cgColor

        textField.borderStyle = .none
        textField.textColor = .mgTextPrimary
        textField.tintColor = .mgAccent
        textField.keyboardAppearance = .dark

        contentView.addSubview(titleLabel)
        contentView.addSubview(containerView)
        containerView.addSubview(textField)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(6)
            make.height.equalTo(52)
        }

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }

    func configure(title: String,
                   placeholder: String,
                   text: String?,
                   keyboardType: UIKeyboardType) {
        titleLabel.text = title
        textField.text = text
        textField.keyboardType = keyboardType

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.mgTextSecondary.withAlphaComponent(0.7)
            ]
        )
    }
}
