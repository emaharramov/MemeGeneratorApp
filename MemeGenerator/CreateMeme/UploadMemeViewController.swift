//
//  UploadMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

// MARK: - ViewController

final class UploadMemeViewController: UIViewController,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIColorPickerViewControllerDelegate {

    private let viewModel = UploadMemeViewModel(isPremiumUser: true)

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let editorContainer = UIView()
    private let baseImageView = UIImageView()
    private let overlayContainer = UIView()
    private let hintLabel = UILabel()

    private let textColorTitleLabel = UILabel()
    private let colorContainer = UIView()
    private let eyedropperButton = UIButton(type: .system)

    private let galleryButton = UIButton(type: .system)
    private let cameraButton = UIButton(type: .system)
    private let addTextButton = UIButton(type: .system)
    private let clearTextButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private let watermarkPreviewLabel = UILabel()

    private let backgroundGradient = CAGradientLayer()

    // MARK: - Overlay State

    private var overlays: [MemeTextOverlayView] = []
    private var activeOverlay: MemeTextOverlayView?
    private var isEditMode: Bool = false {
        didSet { updateEditMode() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientBackground()
        setupScrollLayout()
        setupEditor()
        setupBottomControls()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    // MARK: - Gradient

    private func setupGradientBackground() {
        // Login screen-ə bənzər yumşaq gradient
        backgroundGradient.colors = [
            UIColor.systemPink.withAlphaComponent(0.9).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.75).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.85).cgColor
        ]
        backgroundGradient.locations = [0.0, 0.45, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint   = CGPoint(x: 0, y: 1)

        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    // MARK: - Layout

    private func setupScrollLayout() {
        view.addSubview(scrollView)
        scrollView.backgroundColor = .clear
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func setupEditor() {
        editorContainer.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        editorContainer.layer.cornerRadius = 16
        editorContainer.clipsToBounds = true

        contentView.addSubview(editorContainer)
        editorContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(editorContainer.snp.width).multipliedBy(0.75)
        }

        baseImageView.contentMode = .scaleAspectFit
        baseImageView.backgroundColor = .black
        editorContainer.addSubview(baseImageView)
        baseImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayContainer.backgroundColor = .clear
        editorContainer.addSubview(overlayContainer)
        overlayContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        watermarkPreviewLabel.text = viewModel.appWatermarkText
        watermarkPreviewLabel.font = .boldSystemFont(ofSize: 40)
        watermarkPreviewLabel.textColor = UIColor.white.withAlphaComponent(0.18)
        watermarkPreviewLabel.textAlignment = .center
        watermarkPreviewLabel.numberOfLines = 0
        watermarkPreviewLabel.transform = CGAffineTransform(rotationAngle: -.pi / 8)

        overlayContainer.addSubview(watermarkPreviewLabel)
        watermarkPreviewLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }

        hintLabel.text = "Tap on the image to add text"
        hintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hintLabel.textColor = .secondaryLabel
        hintLabel.textAlignment = .center

        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(editorContainer.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        overlayContainer.addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCanvasLongPress(_:)))
        overlayContainer.addGestureRecognizer(longPress)
    }

    private func setupBottomControls() {
        textColorTitleLabel.text = "Text color"
        textColorTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        textColorTitleLabel.textColor = .label

        contentView.addSubview(textColorTitleLabel)
        textColorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        colorContainer.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        colorContainer.layer.cornerRadius = 14

        contentView.addSubview(colorContainer)
        colorContainer.snp.makeConstraints { make in
            make.top.equalTo(textColorTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        eyedropperButton.setImage(UIImage(systemName: "eyedropper.halffull"), for: .normal)
        eyedropperButton.tintColor = .label
        eyedropperButton.addTarget(self, action: #selector(openColorPicker), for: .touchUpInside)

        colorContainer.addSubview(eyedropperButton)
        eyedropperButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        // Only icons
        setupBottomButton(
            galleryButton,
            systemImageName: "photo.on.rectangle",
            color: .systemBlue
        )
        setupBottomButton(
            cameraButton,
            systemImageName: "camera.fill",
            color: .systemIndigo
        )
        setupBottomButton(
            addTextButton,
            systemImageName: "textformat.size.larger",
            color: .systemOrange
        )
        setupBottomButton(
            clearTextButton,
            systemImageName: "trash",
            color: .systemRed
        )
        setupBottomButton(
            saveButton,
            systemImageName: "square.and.arrow.down.fill",
            color: .systemGreen
        )

        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        addTextButton.addTarget(self, action: #selector(addTextButtonTapped), for: .touchUpInside)
        clearTextButton.addTarget(self, action: #selector(clearAllText), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [
            galleryButton, cameraButton, addTextButton, clearTextButton, saveButton
        ])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10

        contentView.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(colorContainer.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().inset(24)
        }
    }

    private func setupBottomButton(
        _ button: UIButton,
        systemImageName: String,
        color: UIColor
    ) {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: systemImageName, withConfiguration: config)

        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = color

        button.layer.cornerRadius = 18
        button.clipsToBounds = true

        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onImageChanged = { [weak self] image in
            guard let self else { return }
            self.baseImageView.image = image

            if let img = image {
                let aspect = img.size.height / max(img.size.width, 1)
                self.editorContainer.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(16)
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(self.editorContainer.snp.width).multipliedBy(aspect)
                }
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        viewModel.onSavingStateChange = { [weak self] isSaving in
            guard let self else { return }
            if isSaving {
                self.showToast(message: "Saving meme…")
            }
        }

        viewModel.onSaveSuccess = { [weak self] in
            self?.showToast(message: "Saved to Photos ✅")
        }

        viewModel.onError = { [weak self] message in
            self?.showToast(message: message)
        }
    }

    // MARK: - Overlay helpers

    private func createOverlay(at point: CGPoint, initialText: String = "Your text") {
        let overlay = MemeTextOverlayView()
        overlay.label.text = initialText

        overlay.onTap = { [weak self, weak overlay] in
            guard let self, let overlay else { return }
            self.activeOverlay = overlay
            self.presentTextEdit(for: overlay)
        }

        overlay.onDelete = { [weak self, weak overlay] in
            guard let self, let overlay else { return }
            self.removeOverlay(overlay)
        }

        overlay.onDragChanged = { [weak self, weak overlay] _ in
            guard let self, let overlay else { return }
            self.activeOverlay = overlay
        }

        overlayContainer.addSubview(overlay)
        let size = CGSize(width: 140, height: 60)
        overlay.frame = CGRect(origin: .zero, size: size)
        overlay.center = point.clamped(in: overlayContainer.bounds.insetBy(dx: 20, dy: 20))

        overlays.append(overlay)
        activeOverlay = overlay
        updateEditMode()
    }

    private func removeOverlay(_ overlay: MemeTextOverlayView) {
        if let index = overlays.firstIndex(where: { $0 === overlay }) {
            overlays.remove(at: index)
        }
        overlay.removeFromSuperview()
        if activeOverlay === overlay { activeOverlay = nil }
    }

    private func clearAllOverlays() {
        overlays.forEach { $0.removeFromSuperview() }
        overlays.removeAll()
        activeOverlay = nil
    }

    private func updateEditMode() {
        overlays.forEach { $0.isInEditMode = isEditMode }
    }

    private func presentTextEdit(for overlay: MemeTextOverlayView) {
        let alert = UIAlertController(
            title: "Edit text",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { field in
            field.text = overlay.label.text
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let newText = alert.textFields?.first?.text ?? ""
            overlay.label.text = newText
            self.activeOverlay = overlay
        }))

        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func handleCanvasTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: overlayContainer)

        // Edit mode aktivdirsə – sadəcə edit mode-dan çıx, yeni text yaranmasın
        if isEditMode {
            isEditMode = false
            return
        }

        guard baseImageView.image != nil else { return }
        createOverlay(at: location)
    }

    @objc private func handleCanvasLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            isEditMode = true
        }
    }

    @objc private func openColorPicker() {
        guard activeOverlay != nil else {
            showToast(message: "Tap on a text to edit color")
            return
        }
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.selectedColor = activeOverlay?.label.textColor ?? .white
        present(picker, animated: true)
    }

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

    @objc private func addTextButtonTapped() {
        let center = CGPoint(x: overlayContainer.bounds.midX, y: overlayContainer.bounds.midY)
        createOverlay(at: center)
    }

    @objc private func clearAllText() {
        clearAllOverlays()
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        viewModel.saveMeme(from: editorContainer, includeWatermark: false)
    }

    // MARK: - UIImagePicker Delegate

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            clearAllOverlays()
            viewModel.setImage(img)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - Color Picker Delegate

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let overlay = activeOverlay else { return }
        overlay.label.textColor = viewController.selectedColor
    }
}

// MARK: - CGPoint helper

private extension CGPoint {
    func clamped(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: max(rect.minX, min(rect.maxX, x)),
            y: max(rect.minY, min(rect.maxY, y))
        )
    }
}
