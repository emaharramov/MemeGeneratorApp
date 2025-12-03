//
//  UploadMemeRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//


import UIKit

final class UploadMemeRepositoryImpl: NSObject, UploadMemeRepository {
    
    private var completionHandler: ((Result<Void, Error>) -> Void)?
    
    func saveToPhotos(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completionHandler = completion
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
        if let error {
            completionHandler?(.failure(error))
        } else {
            completionHandler?(.success(()))
        }
        completionHandler = nil
    }
}
