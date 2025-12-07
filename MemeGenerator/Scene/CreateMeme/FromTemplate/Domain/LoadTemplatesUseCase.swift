//
//  LoadTemplatesUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

protocol LoadTemplatesUseCaseProtocol {
    func execute(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    )
}

final class LoadTemplatesUseCase: LoadTemplatesUseCaseProtocol {

    private let repository: FromTemplateRepository

    init(repository: FromTemplateRepository) {
        self.repository = repository
    }

    func execute(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    ) {
        repository.fetchTemplates(completion: completion)
    }
}
