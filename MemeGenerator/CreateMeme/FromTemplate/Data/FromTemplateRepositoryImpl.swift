//
//  FromTemplateRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

final class FromTemplateRepositoryImpl: FromTemplateRepository {

    private let service: MemeService

    init(service: MemeService = .shared) {
        self.service = service
    }

    func fetchTemplates(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    ) {
        service.fetchTemplates { list, error in
            if let error {
                completion(.failure(MemeDataError.api(message: error)))
                return
            }
            guard let list else {
                completion(.failure(MemeDataError.invalidResponse))
                return
            }
            completion(.success(list))
        }
    }

    func generateMeme(
        userId: String,
        prompt: String,
        templateId: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        service.generateMeme(
            userId: userId,
            prompt: prompt,
            templateId: templateId
        ) { [weak self] dto, error in
            guard let self else { return }

            if let error {
                completion(.failure(MemeDataError.api(message: error)))
                return
            }

            guard let dto, !dto.imageUrl.isEmpty else {
                completion(.failure(MemeDataError.invalidResponse))
                return
            }

            self.service.loadImage(url: dto.imageUrl) { image in
                guard let image else {
                    completion(.failure(MemeDataError.invalidResponse))
                    return
                }
                completion(.success(image))
            }
        }
    }

    // 🔹 UploadMeme üçün template şəkli yükləmək
    func loadTemplateImage(
        from url: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        service.loadImage(url: url) { image in
            guard let image else {
                completion(.failure(MemeDataError.invalidResponse))
                return
            }
            completion(.success(image))
        }
    }
}
