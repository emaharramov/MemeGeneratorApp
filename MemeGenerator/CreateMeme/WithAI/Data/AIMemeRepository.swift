//
//  AIMemeRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol AIMemeRepository {
    func generateMeme(
        userId: String,
        prompt: String,
        completion: @escaping (Result<String, AIMemeError>) -> Void
    )

    func loadImage(
        from urlString: String,
        completion: @escaping (Result<UIImage, AIMemeError>) -> Void
    )
}
