//
//  UploadMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class UploadMemeViewController: UIViewController,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIColorPickerViewControllerDelegate {

    private let viewModel = UploadMemeViewModel(isPremiumUser: true)

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = MemeHeaderView(
        title: "Custom Meme",
        subtitle: "Use your own image and add custom text."
    )

    private let editorContainer = UIView()
    private let baseImageView = UIImageView()
    private let overlayContainer = UIView()

    private let placeholderStack = UIStackView()
    private let placeholderIcon = UIImageView()
    private let placeholderLabel = UILabel()

    private let watermarkPreviewLabel = UILabel()
    private let dashedBorderLayer = CAShapeLayer()

    private let hintLabel = UILabel()

    private let textColorTitleLabel = UILabel()
    private let colorContainer = UIView()
    private let eyedropperButton = UIButton(type: .system)

    private let shareActionsView = MemeShareActionsView()
    private let toolsView = MemeEditToolsView()
    // MARK: - Overlay State

    private var overlays: [MemeTextOverlayView] = []
    private var activeOverlay: MemeTextOverlayView?
    private var isEditMode: Bool = false {
        didSet { updateEditMode() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        setupScrollLayout()
        setupHeader()
        setupEditor()
        setupTextColorAndActions()
        setupBindings()

        updatePlaceholderState(hasImage: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        dashedBorderLayer.frame = editorContainer.bounds
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: editorContainer.bounds,
            cornerRadius: 16
        ).cgPath
    }

    // MARK: - Layout

    private func setupScrollLayout() {
        view.addSubview(scrollView)
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

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

    private func setupHeader() {
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupEditor() {
        editorContainer.backgroundColor = .systemBackground
        editorContainer.layer.cornerRadius = 16
        editorContainer.clipsToBounds = true

        // dashed border – upload placeholder kimi
        dashedBorderLayer.strokeColor = UIColor.systemGray4.cgColor
        dashedBorderLayer.fillColor = UIColor.clear.cgColor
        dashedBorderLayer.lineDashPattern = [6, 4]
        dashedBorderLayer.lineWidth = 1
        editorContainer.layer.addSublayer(dashedBorderLayer)

        contentView.addSubview(editorContainer)
        editorContainer.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(editorContainer.snp.width).multipliedBy(0.75)
        }

        baseImageView.contentMode = .scaleAspectFit
        baseImageView.backgroundColor = .clear
        editorContainer.addSubview(baseImageView)
        baseImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayContainer.backgroundColor = .clear
        editorContainer.addSubview(overlayContainer)
        overlayContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Placeholder (add_photo_alternate style)
        placeholderIcon.image = UIImage(systemName: "photo.on.rectangle")
        placeholderIcon.tintColor = .systemGray3

        placeholderLabel.text = "Tap to upload or take a photo"
        placeholderLabel.font = .systemFont(ofSize: 14)
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0

        placeholderStack.axis = .vertical
        placeholderStack.alignment = .center
        placeholderStack.spacing = 8
        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        editorContainer.addSubview(placeholderStack)
        placeholderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
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

    private func setupTextColorAndActions() {
        // Başlıq – artıq yalnız "Text color" yox, ümumi tools kimi dursun
        textColorTitleLabel.text = "Tools"
        textColorTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        textColorTitleLabel.textColor = .label

        contentView.addSubview(textColorTitleLabel)
        textColorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // ↓ Yeni tools view (Gallery / Camera / Text color)
        contentView.addSubview(toolsView)
        toolsView.snp.makeConstraints { make in
            make.top.equalTo(textColorTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }

        toolsView.onGallery = { [weak self] in
            // birbaşa galeriya
            self?.openGallery()
        }

        toolsView.onCamera = { [weak self] in
            // birbaşa kamera
            self?.openCamera()
        }

        toolsView.onColor = { [weak self] in
            // mövcud color picker logikanı istifadə edirik
            self?.openColorPicker()
        }

        // ↓ ShareActionsView – eyni qalır, sadəcə toolsView-dən sonra yerləşir
        contentView.addSubview(shareActionsView)
        shareActionsView.snp.makeConstraints { make in
            make.top.equalTo(toolsView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().inset(24)
        }

        shareActionsView.onSave = { [weak self] in
            self?.handleSave()
        }
        shareActionsView.onShare = { [weak self] in
            self?.handleShare()
        }
        shareActionsView.onTryAgain = { [weak self] in
            self?.handleReset()
        }
    }



    // MARK: - Placeholder state

    private func updatePlaceholderState(hasImage: Bool) {
        placeholderStack.isHidden = hasImage
        watermarkPreviewLabel.isHidden = !hasImage
        hintLabel.isHidden = !hasImage

        overlayContainer.isUserInteractionEnabled = hasImage
        if !hasImage {
            clearAllOverlays()
        }
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onImageChanged = { [weak self] image in
            guard let self else { return }
            self.baseImageView.image = image

            if let img = image {
                let aspect = img.size.height / max(img.size.width, 1)
                self.editorContainer.snp.remakeConstraints { make in
                    make.top.equalTo(self.headerView.snp.bottom).offset(16)
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(self.editorContainer.snp.width).multipliedBy(aspect)
                }
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
                self.updatePlaceholderState(hasImage: true)
            } else {
                self.updatePlaceholderState(hasImage: false)
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

        // Şəkil yoxdursa → upload sheet (gallery / camera)
        guard baseImageView.image != nil else {
            presentImageSourceActionSheet()
            return
        }

        // Edit mode aktivdirsə – sadəcə edit moddan çıx
        if isEditMode {
            isEditMode = false
            return
        }

        createOverlay(at: location)
    }

    @objc private func handleCanvasLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            isEditMode = true
        }
    }

    private func presentImageSourceActionSheet() {
        let sheet = UIAlertController(title: "Add Image", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] _ in
            self?.openGallery()
        }))

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
                self?.openCamera()
            }))
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
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

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - ShareActions handlers

    private func handleSave() {
        guard baseImageView.image != nil else {
            showToast(message: "Add an image first")
            return
        }
        view.endEditing(true)
        viewModel.saveMeme(from: editorContainer, includeWatermark: false)
    }

    private func handleShare() {
        guard let image = renderMemeImage() else {
            showToast(message: "Add an image first")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func handleReset() {
        // regenerate → hər şeyi sıfırla
        baseImageView.image = nil
        viewModel.onImageChanged?(nil)   // əgər closure optional-dırsa işə düşəcək
        clearAllOverlays()
        updatePlaceholderState(hasImage: false)
    }

    private func renderMemeImage() -> UIImage? {
        view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: editorContainer.bounds)
        return renderer.image { _ in
            editorContainer.drawHierarchy(in: editorContainer.bounds, afterScreenUpdates: true)
        }
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
