//
//  MemeEditToolsView.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import UIKit
import SnapKit

final class MemeEditToolsView: UIView {

    var onGallery: (() -> Void)?
    var onCamera: (() -> Void)?
    var onTemplates: (() -> Void)?
    var onColor: (() -> Void)?

    private let galleryButton = UIButton(type: .system)
    private let cameraButton = UIButton(type: .system)
    private let templatesButton = UIButton(type: .system)
    private let colorButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        configure(button: galleryButton, title: "Gallery", systemImage: "photo.on.rectangle")
        configure(button: cameraButton, title: "Camera", systemImage: "camera")
        configure(button: templatesButton, title: "Templates", systemImage: "square.grid.2x2")
        configure(button: colorButton, title: "Text color", systemImage: "eyedropper")

        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        templatesButton.addTarget(self, action: #selector(templatesTapped), for: .touchUpInside)
        colorButton.addTarget(self, action: #selector(colorTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            galleryButton, cameraButton, templatesButton, colorButton
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(button: UIButton, title: String, systemImage: String) {
        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        config.image = UIImage(systemName: systemImage, withConfiguration: symbolConfig)
        config.imagePlacement = .top
        config.imagePadding = 6

        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: 13, weight: .medium)
        config.attributedTitle = titleAttr
        config.baseForegroundColor = .mgTextSecondary

        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6)

        button.configuration = config
        button.backgroundColor = .mgCard
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
    }

    @objc private func galleryTapped()   { onGallery?() }
    @objc private func cameraTapped()    { onCamera?() }
    @objc private func templatesTapped() { onTemplates?() }
    @objc private func colorTapped()     { onColor?() }
}

