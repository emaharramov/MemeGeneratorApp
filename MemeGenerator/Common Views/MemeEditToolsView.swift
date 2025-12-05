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
    var onTemplate: (() -> Void)?

    private let galleryButton = UIButton(type: .system)
    private let cameraButton = UIButton(type: .system)
    private let templateButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        configure(button: galleryButton,
                  title: "Gallery",
                  systemImage: "photo.on.rectangle")
        configure(button: cameraButton,
                  title: "Camera",
                  systemImage: "camera")
        configure(button: templateButton,
                  title: "Template",
                  systemImage: "square.grid.2x2")

        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        templateButton.addTarget(self, action: #selector(templateTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            galleryButton,
            cameraButton,
            templateButton
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

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 6,
            bottom: 10,
            trailing: 6
        )

        button.configuration = config
        button.backgroundColor = .mgCard
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
    }

    @objc private func galleryTapped()   { onGallery?() }
    @objc private func cameraTapped()    { onCamera?() }
    @objc private func templateTapped()  { onTemplate?() }
}
