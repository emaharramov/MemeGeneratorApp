//
//  UploadMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit

final class UploadMemeViewController: BaseController<UploadMemeViewModel>,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIColorPickerViewControllerDelegate {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = MemeHeaderView(
        title: "Custom Meme",
        subtitle: "Use your own image and add custom text."
    )

    private let editorCard = UIView()
    private let baseImageView = UIImageView()
    private let overlayContainer = UIView()

    private let placeholderStack = UIStackView()
    private let placeholderIcon = UIImageView()
    private let placeholderLabel = UILabel()

    private let watermarkPreviewLabel = UILabel()
    private let dashedBorderLayer = CAShapeLayer()

    private let hintLabel = UILabel()

    private let toolsTitleLabel = UILabel()
    private let toolsView = MemeEditToolsView()          // Gallery / Camera / Templates / Color

    private let shareActionsView = MemeShareActionsView() // Save / Share / Try Again / Reset

    // MARK: - Overlay State

    private var overlays: [MemeTextOverlayView] = []
    private var activeOverlay: MemeTextOverlayView?
    private var isEditMode: Bool = false {
        didSet { updateEditMode() }
    }

    // MARK: - Templates

    private var templates: [TemplateDTO] = []

    // MARK: - Init

    override init(viewModel: UploadMemeViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mgBackground
        configureNavigation(title: "Create")

        setupScrollLayout()
        setupHeader()
        setupEditorCard()
        setupToolsAndActions()
        setupBindings()

        updatePlaceholderState(hasImage: false)
        loadTemplates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        dashedBorderLayer.frame = editorCard.bounds
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: editorCard.bounds,
            cornerRadius: 20
        ).cgPath
    }

    // MARK: - Layout & Style

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

    private func styleCard(_ view: UIView) {
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
    }

    private func setupEditorCard() {
        styleCard(editorCard)

        // dashed border – yalnız placeholder olanda görünür
        dashedBorderLayer.strokeColor = UIColor.mgCardStroke.withAlphaComponent(0.5).cgColor
        dashedBorderLayer.fillColor = UIColor.clear.cgColor
        dashedBorderLayer.lineDashPattern = [6, 4]
        dashedBorderLayer.lineWidth = 1
        editorCard.layer.addSublayer(dashedBorderLayer)

        contentView.addSubview(editorCard)
        editorCard.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(editorCard.snp.width).multipliedBy(0.75)
        }

        baseImageView.contentMode = .scaleAspectFit
        baseImageView.backgroundColor = .clear

        editorCard.addSubview(baseImageView)
        baseImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        overlayContainer.backgroundColor = .clear
        editorCard.addSubview(overlayContainer)
        overlayContainer.snp.makeConstraints { make in
            make.edges.equalTo(baseImageView.snp.edges)
        }

        // Placeholder
        placeholderIcon.image = UIImage(systemName: "photo.on.rectangle")
        placeholderIcon.tintColor = .systemGray3

        placeholderLabel.text = "Tap to upload or take a photo"
        placeholderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        placeholderLabel.textColor = .mgTextSecondary
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 0

        placeholderStack.axis = .vertical
        placeholderStack.alignment = .center
        placeholderStack.spacing = 8
        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        editorCard.addSubview(placeholderStack)
        placeholderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Watermark preview (yalnız image olanda)
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
            make.top.equalTo(editorCard.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        overlayContainer.addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCanvasLongPress(_:)))
        overlayContainer.addGestureRecognizer(longPress)
    }

    private func setupToolsAndActions() {
        toolsTitleLabel.text = "Tools"
        toolsTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        toolsTitleLabel.textColor = .mgTextPrimary

        contentView.addSubview(toolsTitleLabel)
        toolsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        contentView.addSubview(toolsView)
        toolsView.snp.makeConstraints { make in
            make.top.equalTo(toolsTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }

        // Tools callbacks
        toolsView.onGallery = { [weak self] in
            self?.openGallery()
        }

        toolsView.onCamera = { [weak self] in
            self?.openCamera()
        }

        toolsView.onTemplates = { [weak self] in
            self?.openTemplatePicker()
        }

        toolsView.onColor = { [weak self] in
            self?.openColorPicker()
        }

        // Share Actions – hər zaman görünür
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
        // Try Again – yalnız text overlay-ləri təmizləyir
        shareActionsView.onTryAgain = { [weak self] in
            self?.clearAllOverlays()
        }
        // Reset – hər şeyi sıfırlayır (image + overlays)
        shareActionsView.onRegenerate = { [weak self] in
            self?.handleReset()
        }
    }

    // MARK: - Templates

    private func loadTemplates() {
        MemeService.shared.fetchTemplates { [weak self] list, error in
            guard let self else { return }

            if let error {
                print("Templates error:", error)
                return
            }
            self.templates = list ?? []
        }
    }

    private func openTemplatePicker() {
        guard !templates.isEmpty else {
            showToast(message: "Templates are loading, please try again.")
            loadTemplates()
            return
        }

        let picker = TemplatePickerViewController(templates: templates)
        picker.onTemplateSelected = { [weak self] template in
            guard let self else { return }
            MemeService.shared.loadImage(url: template.url) { image in
                DispatchQueue.main.async {
                    self.clearAllOverlays()
                    self.viewModel.setImage(image)
                }
            }
        }

        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(picker, animated: true)
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
                self.editorCard.snp.remakeConstraints { make in
                    make.top.equalTo(self.headerView.snp.bottom).offset(16)
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(self.editorCard.snp.width).multipliedBy(aspect)
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

        guard baseImageView.image != nil else {
            presentImageSourceActionSheet()
            return
        }

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
        viewModel.saveMeme(from: editorCard, includeWatermark: false)
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
        baseImageView.image = nil
        viewModel.setImage(nil)
        clearAllOverlays()
        updatePlaceholderState(hasImage: false)

        let top = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
        scrollView.setContentOffset(top, animated: true)
    }

    private func renderMemeImage() -> UIImage? {
        view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: editorCard.bounds)
        return renderer.image { _ in
            editorCard.drawHierarchy(in: editorCard.bounds, afterScreenUpdates: true)
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
