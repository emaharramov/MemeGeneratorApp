//
//  MemeTemplateRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

enum MemeTemplateDataError: LocalizedError {
    case api(message: String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .api(let message):
            return message
        case .invalidResponse:
            return "Unexpected response from server"
        }
    }
}

final class MemeTemplateRepositoryImpl: MemeTemplateRepository {
    
    private let service: MemeService
    
    init(service: MemeService = .shared) {
        self.service = service
    }
    
    func fetchTemplates(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    ) {
        service.fetchTemplates { list, error in
            if let error {
                completion(.failure(MemeTemplateDataError.api(message: error)))
                return
            }
            guard let list else {
                completion(.failure(MemeTemplateDataError.invalidResponse))
                return
            }
            completion(.success(list))
        }
    }
    
    func loadTemplateImage(
        from url: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        service.loadImage(url: url) { image in
            guard let image else {
                completion(.failure(MemeTemplateDataError.invalidResponse))
                return
            }
            completion(.success(image))
        }
    }
}
