//
//  FeedUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import Foundation

final class FeedUseCase {

    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(
        page: Int,
        completion: @escaping (Result<FeedMemes, FeedError>) -> Void
    ) {
        repository.getAllAIMemes(page: page, completion: completion)
    }
}
