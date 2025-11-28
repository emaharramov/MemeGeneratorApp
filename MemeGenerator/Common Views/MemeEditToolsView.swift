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
    var onColor:  (() -> Void)?

    private let galleryButton = UIButton(type: .system)
    private let cameraButton  = UIButton(type: .system)
    private let colorButton   = UIButton(type: .system)

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
                  systemImage: "camera.fill")

        configure(button: colorButton,
                  title: "Text color",
                  systemImage: "eyedropper.halffull",
                  accentColor: .systemPurple)

        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped),  for: .touchUpInside)
        colorButton.addTarget(self,  action: #selector(colorTapped),   for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [galleryButton, cameraButton, colorButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configure(
        button: UIButton,
        title: String,
        systemImage: String,
        accentColor: UIColor? = nil
    ) {
        var config = UIButton.Configuration.plain()

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        config.image = UIImage(systemName: systemImage, withConfiguration: symbolConfig)
        config.imagePlacement = .top
        config.imagePadding = 4

        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: 12.5, weight: .medium)
        config.attributedTitle = titleAttr

        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6)

        button.configuration = config

        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0.6
        button.layer.borderColor = UIColor.systemGray4.withAlphaComponent(0.9).cgColor

        if let accentColor {
            button.tintColor = accentColor
        }
    }

    @objc private func galleryTapped() { onGallery?() }
    @objc private func cameraTapped()  { onCamera?()  }
    @objc private func colorTapped()   { onColor?()   }
}
