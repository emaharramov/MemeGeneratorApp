//
//  MemeTemplateRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

protocol MemeTemplateRepository {
    func fetchTemplates(
        completion: @escaping (Result<[TemplateDTO], Error>) -> Void
    )
    
    func loadTemplateImage(
        from url: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}
