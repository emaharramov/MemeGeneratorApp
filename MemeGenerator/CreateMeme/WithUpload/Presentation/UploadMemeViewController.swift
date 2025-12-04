//
//  UploadMemeViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit
import SnapKit
import Combine

final class UploadMemeViewController: BaseController<UploadMemeViewModel>,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate,
                                      UIColorPickerViewControllerDelegate {

    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = .clear
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = false
        return v
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let headerView: MemeHeaderView = {
        MemeHeaderView(
            title: "Custom Meme",
            subtitle: "Use your own image and add custom text."
        )
    }()

    private let editorCard: UIView = {
        let v = UIView()
        return v
    }()

    private let baseImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.backgroundColor = .clear
        return v
    }()

    private let overlayContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let placeholderStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 8
        return s
    }()

    private let placeholderIcon: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "photo.on.rectangle")
        v.tintColor = .systemGray3
        return v
    }()

    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to upload or take a photo"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .mgTextSecondary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    private let watermarkPreviewLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 40)
        lbl.textColor = UIColor.white.withAlphaComponent(0.18)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.transform = CGAffineTransform(rotationAngle: -.pi / 8)
        return lbl
    }()

    private let dashedBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.mgCardStroke.withAlphaComponent(0.5).cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineDashPattern = [6, 4]
        layer.lineWidth = 1
        return layer
    }()

    private let hintLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap on the image to add text"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        return lbl
    }()

    private let toolsTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tools"
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .mgTextPrimary
        return lbl
    }()

    private let toolsView = MemeEditToolsView()
    private let shareActionsView = MemeShareActionsView()

    private var overlays: [MemeTextOverlayView] = []
    private var activeOverlay: MemeTextOverlayView?
    private var isEditMode: Bool = false {
        didSet { updateEditMode() }
    }

    private var cancellables = Set<AnyCancellable>()

    override init(viewModel: UploadMemeViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        viewModel.loadTemplatesIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        dashedBorderLayer.frame = editorCard.bounds
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: editorCard.bounds,
            cornerRadius: 20
        ).cgPath
    }

    private func setupScrollLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func styleCard(_ view: UIView) {
        view.backgroundColor = .mgCard
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mgCardStroke.cgColor
    }

    private func setupHeader() {
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupEditorCard() {
        styleCard(editorCard)
        editorCard.layer.addSublayer(dashedBorderLayer)

        contentView.addSubview(editorCard)
        editorCard.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(editorCard.snp.width).multipliedBy(0.75)
        }

        editorCard.addSubview(baseImageView)
        baseImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        editorCard.addSubview(overlayContainer)
        overlayContainer.snp.makeConstraints { make in
            make.edges.equalTo(baseImageView.snp.edges)
        }

        placeholderStack.addArrangedSubview(placeholderIcon)
        placeholderStack.addArrangedSubview(placeholderLabel)

        editorCard.addSubview(placeholderStack)
        placeholderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        watermarkPreviewLabel.text = viewModel.appWatermarkText
        overlayContainer.addSubview(watermarkPreviewLabel)
        watermarkPreviewLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
        }

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
            self?.clearAllOverlays()
        }
        shareActionsView.onRegenerate = { [weak self] in
            self?.handleReset()
        }
    }

    private func setupBindings() {
        viewModel.onImageChanged = { [weak self] image in
            guard let self else { return }
            self.baseImageView.image = image
            self.updatePlaceholderState(hasImage: image != nil)
        }

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.showToast(message: message)
            }
            .store(in: &cancellables)

        viewModel.$successMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.showToast(message: message, type: .success)
            }
            .store(in: &cancellables)
    }

    private func openTemplatePicker() {
        if !viewModel.templates.isEmpty {
            presentTemplatePicker(with: viewModel.templates)
            return
        }

        showToast(message: "Loading templates…", type: .info)
        viewModel.loadTemplatesIfNeeded()
    }

    private func presentTemplatePicker(with templates: [TemplateDTO]) {
        guard !templates.isEmpty else {
            showToast(message: "No templates available yet.", type: .error)
            return
        }

        let picker = TemplatePickerViewController(templates: templates)
        picker.onTemplateSelected = { [weak self] template in
            self?.viewModel.applyTemplate(template)
            self?.clearAllOverlays()
        }

        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(picker, animated: true)
    }

    private func updatePlaceholderState(hasImage: Bool) {
        placeholderStack.isHidden = hasImage
        watermarkPreviewLabel.isHidden = !hasImage
        hintLabel.isHidden = !hasImage

        overlayContainer.isUserInteractionEnabled = hasImage
        if !hasImage {
            clearAllOverlays()
        }
    }

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

        let maxWidth = overlayContainer.bounds.width * 0.8
        overlay.adjustSize(maxWidth: maxWidth)

        overlay.center = point.clamped(
            in: overlayContainer.bounds.insetBy(dx: 20, dy: 20)
        )

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
            let maxWidth = self.overlayContainer.bounds.width * 0.8
            overlay.adjustSize(maxWidth: maxWidth)
            self.activeOverlay = overlay
        }))

        present(alert, animated: true)
    }

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
            showToast(message: "Tap on a text to edit color", type: .info)
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

    private func handleSave() {
        guard let image = renderMemeImage() else {
            showToast(message: "Add an image first", type: .info)
            return
        }
        view.endEditing(true)
        viewModel.saveMeme(image: image, includeWatermark: false)
    }

    private func handleShare() {
        guard let image = renderMemeImage() else {
            showToast(message: "Add an image first", type: .info)
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

        guard overlayContainer.bounds.width > 0,
              overlayContainer.bounds.height > 0 else {
            return nil
        }
        let captureRect = overlayContainer.convert(overlayContainer.bounds, to: editorCard)
        let renderer = UIGraphicsImageRenderer(bounds: captureRect)

        let image = renderer.image { _ in
            let drawRect = editorCard.bounds.offsetBy(
                dx: -captureRect.origin.x,
                dy: -captureRect.origin.y
            )
            editorCard.drawHierarchy(in: drawRect, afterScreenUpdates: true)
        }

        return image
    }

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

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let overlay = activeOverlay else { return }
        overlay.label.textColor = viewController.selectedColor
    }
}

private extension CGPoint {
    func clamped(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: max(rect.minX, min(rect.maxX, x)),
            y: max(rect.minY, min(rect.maxY, y))
        )
    }
}
