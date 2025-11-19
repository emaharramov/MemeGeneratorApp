//
//  UploadMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class UploadMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView = UIImageView()
    private let topTextField = UITextField()
    private let bottomTextField = UITextField()
    private let buttonsRow = UIStackView()

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
    }

    private func setupUI() {
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        [topLabel, bottomLabel].forEach {
            $0.textColor = .white
            $0.font = .boldSystemFont(ofSize: 24)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.8
            $0.layer.shadowRadius = 3
            imageView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

//        topTextField.placeholder = "Top text"
//        bottomTextField.placeholder = "Bottom text"
        [topTextField, bottomTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.backgroundColor = .white
        }

        let galleryBtn = UIButton(type: .system)
        galleryBtn.setTitle("Gallery", for: .normal)
        galleryBtn.addTarget(self, action: #selector(openGallery), for: .touchUpInside)

        let cameraBtn = UIButton(type: .system)
        cameraBtn.setTitle("Camera", for: .normal)
        cameraBtn.addTarget(self, action: #selector(openCamera), for: .touchUpInside)

        let applyBtn = UIButton(type: .system)
        applyBtn.setTitle("Apply Text", for: .normal)
        applyBtn.addTarget(self, action: #selector(applyText), for: .touchUpInside)

        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually
        [galleryBtn, cameraBtn, applyBtn].forEach { buttonsRow.addArrangedSubview($0) }

        let textStack = UIStackView(arrangedSubviews: [topTextField, bottomTextField])
        textStack.axis = .vertical
        textStack.spacing = 8

        [imageView, textStack, buttonsRow].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            textStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            buttonsRow.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 12),
            buttonsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsRow.heightAnchor.constraint(equalToConstant: 36),

            topLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 12),
            topLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            topLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),

            bottomLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12),
            bottomLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            bottomLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
        ])
    }

    // MARK: - Actions

    @objc private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func applyText() {
        topLabel.text = topTextField.text
        bottomLabel.text = bottomTextField.text
    }

    // MARK: - UIImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            imageView.image = img
        }
    }
}
