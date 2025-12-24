//
//  HomeRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

import Foundation
import Alamofire

final class FeedRepositoryImpl: FeedRepository {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func getAllAIMemes(
            page: Int,
            completion: @escaping (Result<FeedMemes, FeedError>) -> Void
    ){
        let path = FeedEndpoint.allAIMemes(page: page).path

        networkManager.request(
            path: path,
            model: FeedMemes.self,
            method: .get,
            encodingType: .json
        ) { model, errorMessage in

            if let model {
                completion(.success(model))
            } else {
                let message = errorMessage ?? "Unknown error"
                completion(.failure(.network(message)))
            }
        }
    }
}
