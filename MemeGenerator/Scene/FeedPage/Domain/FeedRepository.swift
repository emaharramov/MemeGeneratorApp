//
//  FeedRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import Foundation

protocol FeedRepository {
    func getAllAIMemes(
        page: Int,
        completion: @escaping (Result<FeedMemes, FeedError>) -> Void
    )
}
