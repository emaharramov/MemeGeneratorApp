//
//  TemplateEditorViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import Photos

final class TemplateEditorViewController: UIViewController {

    private let template: TemplateDTO

    private let imageView = UIImageView()
    private let topLabel = UILabel()
    private let bottomLabel = UILabel()

    private let topTF = UITextField()
    private let bottomTF = UITextField()

    private let saveBtn = UIButton(type: .system)
    private let shareBtn = UIButton(type: .system)

    private var currentImage: UIImage?

    init(template: TemplateDTO) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupUI()
        loadTemplateImage()
    }

    private func setupUI() {

        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true

        topLabel.configureOverlay()
        bottomLabel.configureOverlay()

//        topTF.configureField(placeholder: "Top text")
//        bottomTF.configureField(placeholder: "Bottom text")

        saveBtn.configureAction(title: "Save", color: .systemGreen)
        shareBtn.configureAction(title: "Share", color: .systemBlue)

        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareBtn.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        [imageView, topLabel, bottomLabel, topTF, bottomTF, saveBtn, shareBtn].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            topLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 12),
            topLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            topLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),

            bottomLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            bottomLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            bottomLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),

            topTF.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            topTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topTF.heightAnchor.constraint(equalToConstant: 36),

            bottomTF.topAnchor.constraint(equalTo: topTF.bottomAnchor, constant: 8),
            bottomTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomTF.heightAnchor.constraint(equalToConstant: 36),

            saveBtn.topAnchor.constraint(equalTo: bottomTF.bottomAnchor, constant: 16),
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveBtn.heightAnchor.constraint(equalToConstant: 36),
            saveBtn.widthAnchor.constraint(equalToConstant: 120),

            shareBtn.centerYAnchor.constraint(equalTo: saveBtn.centerYAnchor),
            shareBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shareBtn.heightAnchor.constraint(equalToConstant: 36),
            shareBtn.widthAnchor.constraint(equalToConstant: 120),
        ])

        topTF.addTarget(self, action: #selector(applyText), for: .editingChanged)
        bottomTF.addTarget(self, action: #selector(applyText), for: .editingChanged)
    }

    private func loadTemplateImage() {
        MemeService.shared.loadImage(url: template.url) { [weak self] img in
            DispatchQueue.main.async {
                self?.imageView.image = img
                self?.currentImage = img
            }
        }
    }

    @objc private func applyText() {
        topLabel.text = topTF.text
        bottomLabel.text = bottomTF.text
    }

    @objc private func saveTapped() {
        guard let finalImage = generateFinalImage() else { return }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }

            UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
            DispatchQueue.main.async {
                self.showToast(message: "Saved to Photos")
            }
        }
    }

    @objc private func shareTapped() {
        guard let finalImage = generateFinalImage() else { return }

        let vc = UIActivityViewController(activityItems: [finalImage], applicationActivities: nil)
        present(vc, animated: true)
    }

    private func generateFinalImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: imageView.bounds.size)
        return renderer.image { ctx in
            imageView.layer.render(in: ctx.cgContext)
        }
    }
}
