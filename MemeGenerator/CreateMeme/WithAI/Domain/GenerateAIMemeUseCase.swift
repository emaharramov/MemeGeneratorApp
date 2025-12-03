//
//  GenerateAIMemeUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

protocol GenerateAIMemeUseCaseProtocol {
    func execute(
        userId: String,
        prompt: String,
        completion: @escaping (Result<String, AIMemeError>) -> Void
    )
}

final class GenerateAIMemeUseCase: GenerateAIMemeUseCaseProtocol {

    private let repository: AIMemeRepository

    init(repository: AIMemeRepository) {
        self.repository = repository
    }

    func execute(
        userId: String,
        prompt: String,
        completion: @escaping (Result<String, AIMemeError>) -> Void
    ) {
        repository.generateMeme(
            userId: userId,
            prompt: prompt,
            completion: completion
        )
    }
}
