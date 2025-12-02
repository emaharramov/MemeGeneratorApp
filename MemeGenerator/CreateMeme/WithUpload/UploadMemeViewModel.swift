//
//  UploadMemeViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

final class UploadMemeViewModel: BaseViewModel {
    
    // MARK: - Outputs (bindings)
    
    var onImageChanged: ((UIImage?) -> Void)?
    var onSavingStateChange: ((Bool) -> Void)?
    var onSaveSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - State
    
    private(set) var originalImage: UIImage?
    private let isPremiumUser: Bool
    
    /// Watermark üçün app adı – non-premium user-lər üçün istifadə edə bilərsən
    let appWatermarkText: String
    
    // MARK: - Init
    
    init(
        isPremiumUser: Bool = true,
        appWatermarkText: String = "MemeGenerator"
    ) {
        self.isPremiumUser = isPremiumUser
        self.appWatermarkText = appWatermarkText
        super.init()
    }
    
    // MARK: - Image
    
    func setImage(_ image: UIImage?) {
        originalImage = image
        onImageChanged?(image)
    }
    
    // MARK: - Save
    
    /// - Parameters:
    ///   - exportView: Şəkil + overlay-lərin hamısının olduğu view
    ///   - includeWatermark: Premium olmayan istifadəçilər üçün true verə bilərsən
    func saveMeme(from exportView: UIView, includeWatermark: Bool) {
        guard isPremiumUser else {
            onError?("This feature is available only for Premium users.")
            return
        }
        
        guard originalImage != nil else {
            onError?("Please choose an image first.")
            return
        }
        
        onSavingStateChange?(true)
        
        // Əgər watermark əlavə etmək istəyirsənsə, burada müvəqqəti label əlavə edirik
        var watermarkLabel: UILabel?
        
        if includeWatermark {
            let label = UILabel()
            label.text = appWatermarkText
            label.font = .boldSystemFont(ofSize: 32)
            label.textColor = UIColor.white.withAlphaComponent(0.18)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.transform = CGAffineTransform(rotationAngle: -.pi / 8)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            exportView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: exportView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: exportView.centerYAnchor),
                label.widthAnchor.constraint(lessThanOrEqualTo: exportView.widthAnchor, multiplier: 0.8)
            ])
            
            watermarkLabel = label
            exportView.layoutIfNeeded()
        }
        
        let renderer = UIGraphicsImageRenderer(size: exportView.bounds.size)
        let image = renderer.image { _ in
            exportView.drawHierarchy(in: exportView.bounds, afterScreenUpdates: true)
        }
        
        // Watermark label-i əlavə etmişiksə, screenshotdan sonra silirik
        if let label = watermarkLabel {
            label.removeFromSuperview()
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc private func saveCompleted(_ image: UIImage,
                                     didFinishSavingWithError error: Error?,
                                     contextInfo: UnsafeMutableRawPointer?) {
        onSavingStateChange?(false)

        if let error = error {
            onError?("Failed to save meme: \(error.localizedDescription)")
        } else {
            onSaveSuccess?()
        }
    }
}
