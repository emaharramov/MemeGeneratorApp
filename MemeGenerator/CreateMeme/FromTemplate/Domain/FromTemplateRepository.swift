//
//  FromTemplateRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol FromTemplateRepository {
    func fetchTemplates(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    )

    func generateMeme(
        userId: String,
        prompt: String,
        templateId: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )

    func loadTemplateImage(
        from url: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}
