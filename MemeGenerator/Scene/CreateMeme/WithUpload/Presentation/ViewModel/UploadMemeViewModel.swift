//
//  UploadMemeViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class UploadMemeViewModel: BaseViewModel {

    var onImageChanged: ((UIImage?) -> Void)?
    var onTemplatesLoaded: (([TemplateDTO]) -> Void)?
    var templates: [TemplateDTO] = []

    private(set) var originalImage: UIImage?

    let appWatermarkText: String

    private let saveMemeUseCase: SaveMemeUseCaseProtocol
    private let loadTemplatesUseCase: LoadTemplatesUseCaseProtocol
    private let loadTemplateImageUseCase: LoadTemplateImageUseCaseProtocol

    init(
        appWatermarkText: String,
        saveMemeUseCase: SaveMemeUseCaseProtocol,
        loadTemplatesUseCase: LoadTemplatesUseCaseProtocol,
        loadTemplateImageUseCase: LoadTemplateImageUseCaseProtocol
    ) {
        self.appWatermarkText = appWatermarkText
        self.saveMemeUseCase = saveMemeUseCase
        self.loadTemplatesUseCase = loadTemplatesUseCase
        self.loadTemplateImageUseCase = loadTemplateImageUseCase
        super.init()
    }

    func setImage(_ image: UIImage?) {
        originalImage = image
        onImageChanged?(image)
    }

    func loadTemplatesIfNeeded() {
        if !templates.isEmpty {
            onTemplatesLoaded?(templates)
            return
        }

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.loadTemplatesUseCase.execute(completion: completion)
            },
            errorMapper: { error in
                error.localizedDescription
            },
            onSuccess: { [weak self] list in
                guard let self else { return }
                self.templates = list
                self.onTemplatesLoaded?(list)
            }
        )
    }

    func applyTemplate(_ template: TemplateDTO) {
        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.loadTemplateImageUseCase.execute(
                    template: template,
                    completion: completion
                )
            },
            errorMapper: { error in
                error.localizedDescription
            },
            onSuccess: { [weak self] image in
                self?.setImage(image)
            }
        )
    }

    func saveMeme(image: UIImage, includeWatermark: Bool) {
        guard originalImage != nil else {
            showError("Please choose an image first.")
            return
        }

        let finalImage = includeWatermark
            ? addWatermark(to: image)
            : image

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.saveMemeUseCase.execute(
                    image: finalImage,
                    completion: completion
                )
            },
            errorMapper: { error in
                "Failed to save meme: \(error.localizedDescription)"
            },
            onSuccess: { [weak self] in
                self?.showSuccess("Saved to Photos ✅")
            }
        )
    }


    private func addWatermark(to image: UIImage) -> UIImage {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))

            let fontSize = size.width * 0.12
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white.withAlphaComponent(0.18)
            ]

            let text = appWatermarkText as NSString
            let textSize = text.size(withAttributes: attrs)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            let ctx = context.cgContext
            ctx.saveGState()
            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: -.pi / 8)

            let rect = CGRect(
                x: -textSize.width / 2,
                y: -textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: rect, withAttributes: attrs)
            ctx.restoreGState()
        }
    }
}
