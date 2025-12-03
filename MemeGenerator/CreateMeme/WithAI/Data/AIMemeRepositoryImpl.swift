//
//  AIMemeRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

final class AIMemeRepositoryImpl: AIMemeRepository {

    private let service: MemeService

    init(service: MemeService = .shared) {
        self.service = service
    }

    func generateMeme(
        userId: String,
        prompt: String,
        completion: @escaping (Result<String, AIMemeError>) -> Void
    ) {
        service.generateMemeAI(
            userId: userId,
            prompt: prompt
        ) { response, errorString in

            if let errorString {
                completion(.failure(.network(errorString)))
                return
            }

            guard
                let urlString = response?.meme?.imageURL,
                !urlString.isEmpty
            else {
                completion(.failure(.noMeme))
                return
            }

            completion(.success(urlString))
        }
    }

    func loadImage(
        from urlString: String,
        completion: @escaping (Result<UIImage, AIMemeError>) -> Void
    ) {
        service.loadImage(url: urlString) { image in
            guard let image else {
                completion(.failure(.imageDownloadFailed))
                return
            }
            completion(.success(image))
        }
    }
}
