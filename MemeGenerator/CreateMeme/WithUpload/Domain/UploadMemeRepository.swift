//
//  UploadMemeRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol UploadMemeRepository {
    func saveToPhotos(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

