//
//  GenerateMemeFromTemplateUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol GenerateMemeFromTemplateUseCaseProtocol {
    func execute(
        userId: String,
        prompt: String,
        templateId: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}

final class GenerateMemeFromTemplateUseCase: GenerateMemeFromTemplateUseCaseProtocol {

    private let repository: FromTemplateRepository

    init(repository: FromTemplateRepository) {
        self.repository = repository
    }

    func execute(
        userId: String,
        prompt: String,
        templateId: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        repository.generateMeme(
            userId: userId,
            prompt: prompt,
            templateId: templateId,
            completion: completion
        )
    }
}
