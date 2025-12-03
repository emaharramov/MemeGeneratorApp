//
//  LoadAIMemeImageUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol LoadAIMemeImageUseCaseProtocol {
    func execute(
        urlString: String,
        completion: @escaping (Result<UIImage, AIMemeError>) -> Void
    )
}

final class LoadAIMemeImageUseCase: LoadAIMemeImageUseCaseProtocol {

    private let repository: AIMemeRepository

    init(repository: AIMemeRepository) {
        self.repository = repository
    }

    func execute(
        urlString: String,
        completion: @escaping (Result<UIImage, AIMemeError>) -> Void
    ) {
        repository.loadImage(from: urlString, completion: completion)
    }
}
