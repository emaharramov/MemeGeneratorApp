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

    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.textColor = Palette.mgTextPrimary
        tf.tintColor = Palette.mgAccent
        tf.keyboardAppearance = .dark
        return tf
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = Palette.mgTextSecondary
        return lbl
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = Palette.mgCard
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = false
        v.layer.borderWidth = 1
        v.layer.borderColor = Palette.mgCardStroke.cgColor
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
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

    func configure(
        title: String,
        placeholder: String,
        text: String,
        keyboardType: UIKeyboardType,
        isEditable: Bool = true
    ) {
        titleLabel.text = title

        textField.text = text
        textField.keyboardType = keyboardType
        textField.isEnabled = isEditable
        textField.textColor = isEditable ? Palette.mgTextPrimary : Palette.mgTextSecondary

        let placeholderColor = Palette.mgTextSecondary.withAlphaComponent(0.7)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
    }
}
