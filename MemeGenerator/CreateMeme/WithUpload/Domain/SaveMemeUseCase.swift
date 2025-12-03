//
//  SaveMemeUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol SaveMemeUseCaseProtocol {
    func execute(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class SaveMemeUseCase: SaveMemeUseCaseProtocol {
    
    private let repository: UploadMemeRepository
    
    init(repository: UploadMemeRepository) {
        self.repository = repository
    }
    
    func execute(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        repository.saveToPhotos(image: image, completion: completion)
    }
}
