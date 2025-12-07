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
        completion: @escaping (Result<FeedMemes, FeedError>) -> Void
    ) {
        repository.getAllMemes(completion: completion)
    }
}
