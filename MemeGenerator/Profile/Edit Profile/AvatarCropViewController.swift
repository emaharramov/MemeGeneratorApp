//
//  AvatarCropViewController.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import UIKit
import SnapKit

final class AvatarCropViewController: UIViewController, UIScrollViewDelegate {

    // Public
    var onCrop: ((UIImage) -> Void)?

    // Private
    private let image: UIImage

    private let scrollView = UIScrollView()
    private let imageView  = UIImageView()
    private let overlayView = AvatarCropOverlayView()

    private let cancelButton = UIButton(type: .system)
    private let chooseButton = UIButton(type: .system)

    // MARK: - Init

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        configureScrollView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureInitialZoom()
    }

    // MARK: - Setup

    private func setupUI() {
        // Scroll + image
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.backgroundColor = .black
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        // Overlay
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Bottom buttons
        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        chooseButton.setTitle("Choose", for: .normal)
        chooseButton.setTitleColor(.systemYellow, for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)

        bottomBar.addSubview(cancelButton)
        bottomBar.addSubview(chooseButton)

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }

        chooseButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }

    private func configureScrollView() {
        // imageView-in frame-i image ölçüsünə görə
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
    }

    private func configureInitialZoom() {
        guard image.size.width > 0, image.size.height > 0 else { return }

        let boundsSize = scrollView.bounds.size
        let widthScale  = boundsSize.width  / image.size.width
        let heightScale = boundsSize.height / image.size.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale

        // Mərkəzlə
        let imageWidth  = image.size.width * minScale
        let imageHeight = image.size.height * minScale

        let offsetX = max((imageWidth  - boundsSize.width)  / 2, 0)
        let offsetY = max((imageHeight - boundsSize.height) / 2, 0)

        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func chooseTapped() {
        guard let cropped = cropImageInsideCircle() else {
            dismiss(animated: true)
            return
        }
        onCrop?(cropped)
        dismiss(animated: true)
    }

    // MARK: - Cropping

    private func cropImageInsideCircle() -> UIImage? {
        let circleRectInOverlay = overlayView.circleRect

        // 1) Circle rect-i imageView koordinatına çevir
        let circleRectInImageView = overlayView.convert(circleRectInOverlay, to: imageView)

        // 2) imageView.bounds -> orijinal image.size miqyası
        let imageSize = image.size
        let viewSize  = imageView.bounds.size

        guard viewSize.width > 0, viewSize.height > 0 else { return nil }

        let scaleX = imageSize.width  / viewSize.width
        let scaleY = imageSize.height / viewSize.height

        let cropRectInImage = CGRect(
            x: circleRectInImageView.origin.x * scaleX,
            y: circleRectInImageView.origin.y * scaleY,
            width: circleRectInImageView.size.width * scaleX,
            height: circleRectInImageView.size.height * scaleY
        ).integral

        guard
            let cgImage = image.cgImage,
            let croppedCG = cgImage.cropping(to: cropRectInImage)
        else {
            return nil
        }

        let cropped = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
        return cropped
    }
}
