//
//  FeedRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import Foundation

protocol FeedRepository {
    func getAllMemes(
        completion: @escaping (Result<FeedMemes, FeedError>) -> Void
    )
}
