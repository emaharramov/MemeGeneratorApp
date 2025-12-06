//
//  MemeTextEditView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit
import SnapKit

final class MemeTextEditView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit text"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Palette.mgTextPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Change the text, size and color"
        label.font = .systemFont(ofSize: 14)
        label.textColor = Palette.mgTextSecondary
        label.numberOfLines = 0
        return label
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.backgroundColor = Palette.mgLightBackground
        tf.layer.cornerRadius = 14
        tf.textColor = Palette.textFieldTextColor
        tf.tintColor = Palette.textFieldTextColor
        tf.font = .systemFont(ofSize: 16)
        tf.returnKeyType = .done
        return tf
    }()

    private let sizesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let smallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Small", for: .normal)
        return button
    }()

    private let mediumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Medium", for: .normal)
        return button
    }()

    private let largeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Large", for: .normal)
        return button
    }()

    private let colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Text color"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Palette.mgTextSecondary
        return label
    }()

    private let colorRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private let colorPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.mgCardStroke.cgColor
        return view
    }()

    private let colorChangeButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString("Change")
        titleAttr.font = .systemFont(ofSize: 14, weight: .medium)
        config.attributedTitle = titleAttr
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.baseForegroundColor = Palette.textFieldTextColor
        button.configuration = config
        button.backgroundColor = Palette.mgLightBackground
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()

    private let actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        return button
    }()

    var onSave: ((String, CGFloat?, UIColor?) -> Void)?
    var onCancel: (() -> Void)?
    var onColorTap: (() -> Void)?

    private enum SizeOption {
        case small, medium, large, none
    }

    private var selectedSize: SizeOption = .none {
        didSet { updateSizeSelectionUI() }
    }

    private var selectedColor: UIColor? {
        didSet { updateColorPreviewUI() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, currentFontSize: CGFloat?, currentColor: UIColor?) {
        textField.text = text

        if let size = currentFontSize {
            let diffSmall = abs(size - 18)
            let diffMedium = abs(size - 24)
            let diffLarge = abs(size - 32)

            if diffSmall <= diffMedium && diffSmall <= diffLarge {
                selectedSize = .small
            } else if diffMedium <= diffSmall && diffMedium <= diffLarge {
                selectedSize = .medium
            } else {
                selectedSize = .large
            }
        } else {
            selectedSize = .none
        }

        selectedColor = currentColor
    }

    func updateSelectedColor(_ color: UIColor) {
        selectedColor = color
    }

    private func setupUI() {
        backgroundColor = Palette.mgCard
        layer.cornerRadius = 24
        layer.masksToBounds = true

        textField.setLeftPaddingPoints(12)
        textField.setRightPaddingPoints(12)

        [smallButton, mediumButton, largeButton].forEach { button in
            styleOptionButton(button)
            sizesStack.addArrangedSubview(button)
        }

        let colorContainer = UIStackView(arrangedSubviews: [colorTitleLabel, colorRowStack])
        colorContainer.axis = .vertical
        colorContainer.spacing = 6

        colorRowStack.addArrangedSubview(colorPreviewView)
        colorRowStack.addArrangedSubview(colorChangeButton)
        colorRowStack.setCustomSpacing(12, after: colorPreviewView)

        actionsStack.addArrangedSubview(cancelButton)
        actionsStack.addArrangedSubview(saveButton)

        styleOptionButton(cancelButton)
        styleOptionButton(saveButton)

        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            textField,
            sizesStack,
            colorContainer,
            actionsStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12

        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        colorPreviewView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
    }

    private func styleOptionButton(_ button: UIButton) {
        button.backgroundColor = Palette.mgLightBackground
        button.setTitleColor(Palette.textFieldTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
    }

    private func setupActions() {
        smallButton.addTarget(self, action: #selector(handleSmall), for: .touchUpInside)
        mediumButton.addTarget(self, action: #selector(handleMedium), for: .touchUpInside)
        largeButton.addTarget(self, action: #selector(handleLarge), for: .touchUpInside)

        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        colorChangeButton.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
    }

    @objc private func handleSmall() {
        selectedSize = .small
    }

    @objc private func handleMedium() {
        selectedSize = .medium
    }

    @objc private func handleLarge() {
        selectedSize = .large
    }

    @objc private func handleColorChange() {
        onColorTap?()
    }

    @objc private func handleCancel() {
        endEditing(true)
        onCancel?()
    }

    @objc private func handleSave() {
        endEditing(true)

        let text = textField.text ?? ""
        let fontSize: CGFloat?

        switch selectedSize {
        case .small:
            fontSize = 18
        case .medium:
            fontSize = 24
        case .large:
            fontSize = 32
        case .none:
            fontSize = nil
        }

        onSave?(text, fontSize, selectedColor)
    }

    private func updateSizeSelectionUI() {
        let mapping: [(UIButton, SizeOption)] = [
            (smallButton, .small),
            (mediumButton, .medium),
            (largeButton, .large)
        ]

        for (button, option) in mapping {
            if option == selectedSize {
                button.alpha = 1.0
                button.layer.borderWidth = 1
                button.layer.borderColor = Palette.textFieldTextColor
                    .withAlphaComponent(0.8).cgColor
            } else {
                button.alpha = 0.7
                button.layer.borderWidth = 0
                button.layer.borderColor = nil
            }
        }
    }

    private func updateColorPreviewUI() {
        if let color = selectedColor {
            colorPreviewView.backgroundColor = color
        } else {
            colorPreviewView.backgroundColor = .white
        }
    }
}
