//
//  LoadTemplateImageUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol LoadTemplateImageUseCaseProtocol {
    func execute(
        template: TemplateDTO,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}

final class LoadTemplateImageUseCase: LoadTemplateImageUseCaseProtocol {

    private let repository: FromTemplateRepository

    init(repository: FromTemplateRepository) {
        self.repository = repository
    }

    func execute(
        template: TemplateDTO,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        repository.loadTemplateImage(from: template.url, completion: completion)
    }
}
