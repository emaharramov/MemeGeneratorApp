//
//  MemeTextEditView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit
import SnapKit

final class MemeTextEditView: UIView {

    // MARK: - UI

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textField = UITextField()

    private let sizesStack = UIStackView()
    private let smallButton = UIButton(type: .system)
    private let mediumButton = UIButton(type: .system)
    private let largeButton = UIButton(type: .system)

    private let colorTitleLabel = UILabel()
    private let colorRowStack = UIStackView()
    private let colorPreviewView = UIView()
    private let colorChangeButton = UIButton(type: .system)

    private let actionsStack = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // MARK: - Callbacks

    /// text, chosenFontSize (nil -> font saxlanır), chosenColor (nil -> rəng saxlanır)
    var onSave: ((String, CGFloat?, UIColor?) -> Void)?
    var onCancel: (() -> Void)?
    var onColorTap: (() -> Void)?   // UIColorPicker VC-ni controller açacaq

    // MARK: - State

    private enum SizeOption {
        case small, medium, large, none
    }

    private var selectedSize: SizeOption = .none {
        didSet { updateSizeSelectionUI() }
    }

    /// Burada hazırda seçilmiş rəng saxlanılır (configure + color picker vasitəsilə)
    private var selectedColor: UIColor? {
        didSet { updateColorPreviewUI() }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(text: String, currentFontSize: CGFloat?, currentColor: UIColor?) {
        textField.text = text

        // Font size seçimi
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

        // Mövcud rəng preview üçün
        selectedColor = currentColor
    }

    /// Controller color picker-dən rəng seçəndə çağıracaq
    func updateSelectedColor(_ color: UIColor) {
        selectedColor = color
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .mgCard
        layer.cornerRadius = 24
        layer.masksToBounds = true

        titleLabel.text = "Edit text"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .mgTextPrimary

        subtitleLabel.text = "Change the text, size and color"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .mgTextSecondary
        subtitleLabel.numberOfLines = 0

        textField.borderStyle = .none
        textField.backgroundColor = .mgLightBackground
        textField.layer.cornerRadius = 14
        textField.textColor = .textFieldTextColor
        textField.tintColor = .textFieldTextColor
        textField.font = .systemFont(ofSize: 16)
        textField.setLeftPaddingPoints(12)
        textField.setRightPaddingPoints(12)
        textField.returnKeyType = .done

        // Sizes
        sizesStack.axis = .horizontal
        sizesStack.alignment = .fill
        sizesStack.distribution = .fillEqually
        sizesStack.spacing = 8

        [smallButton, mediumButton, largeButton].forEach { btn in
            styleOptionButton(btn)
            sizesStack.addArrangedSubview(btn)
        }

        smallButton.setTitle("Small", for: .normal)
        mediumButton.setTitle("Medium", for: .normal)
        largeButton.setTitle("Large", for: .normal)

        // Color row
        colorTitleLabel.text = "Text color"
        colorTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        colorTitleLabel.textColor = .mgTextSecondary

        colorRowStack.axis = .horizontal
        colorRowStack.alignment = .center
        colorRowStack.spacing = 8

        colorPreviewView.backgroundColor = .white
        colorPreviewView.layer.cornerRadius = 14
        colorPreviewView.layer.masksToBounds = true
        colorPreviewView.layer.borderWidth = 1
        colorPreviewView.layer.borderColor = UIColor.mgCardStroke.cgColor

        colorPreviewView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }

        var colorBtnConfig = UIButton.Configuration.plain()
        var titleAttr = AttributedString("Change")
        titleAttr.font = .systemFont(ofSize: 14, weight: .medium)
        colorBtnConfig.attributedTitle = titleAttr
        colorBtnConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        colorBtnConfig.baseForegroundColor = .textFieldTextColor

        colorChangeButton.configuration = colorBtnConfig
        colorChangeButton.backgroundColor = .mgLightBackground
        colorChangeButton.layer.cornerRadius = 12
        colorChangeButton.layer.masksToBounds = true

        colorRowStack.addArrangedSubview(colorPreviewView)
        colorRowStack.addArrangedSubview(colorChangeButton)
        colorRowStack.setCustomSpacing(12, after: colorPreviewView)

        let colorContainer = UIStackView(arrangedSubviews: [colorTitleLabel, colorRowStack])
        colorContainer.axis = .vertical
        colorContainer.spacing = 6

        // Actions
        actionsStack.axis = .horizontal
        actionsStack.alignment = .fill
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 8

        styleOptionButton(cancelButton)
        styleOptionButton(saveButton)

        cancelButton.setTitle("Cancel", for: .normal)
        saveButton.setTitle("Save", for: .normal)

        actionsStack.addArrangedSubview(cancelButton)
        actionsStack.addArrangedSubview(saveButton)

        // Main stack
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
    }

    private func styleOptionButton(_ button: UIButton) {
        button.backgroundColor = .mgLightBackground
        button.setTitleColor(.textFieldTextColor, for: .normal)
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

    // MARK: - Actions (size)

    @objc private func handleSmall()  { selectedSize = .small  }
    @objc private func handleMedium() { selectedSize = .medium }
    @objc private func handleLarge()  { selectedSize = .large  }

    // MARK: - Actions (color)

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
        case .small:  fontSize = 18
        case .medium: fontSize = 24
        case .large:  fontSize = 32
        case .none:   fontSize = nil
        }

        onSave?(text, fontSize, selectedColor)
    }

    // MARK: - UI state

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
                button.layer.borderColor = UIColor.textFieldTextColor
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
