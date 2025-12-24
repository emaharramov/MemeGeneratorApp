//
//  UserRepositoryImp.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation
import Alamofire

final class UserRepositoryImp: UserRepository {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getUserProfile(
        completion: @escaping (Result<UserProfile, ProfileError>) -> Void
    ) {
        let path = ProfileEndpoint.me.path

        networkManager.request(
            path: path,
            model: UserProfile.self,
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

    func updateProfile(
        _ request: UpdateProfileRequestDTO,
        completion: @escaping (Result<UserProfile, ProfileError>) -> Void
    ) {
        let path = ProfileEndpoint.me.path

        let params: Parameters = [
            "avatarUrl": request.avatarUrl,
            "fullName": request.fullName,
            "username": request.username,
            "email": request.email
        ]

        networkManager.request(
            path: path,
            model: UserProfile.self,
            method: .patch,
            params: params,
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

    func getAiMemes(
        page: Int,
        completion: @escaping (Result<FeedMemes, ProfileError>) -> Void
    ) {
        let path = ProfileEndpoint.aiMemes(userId: AppStorage.shared.userId, page: page).path

        networkManager.request(
            path: path,
            model: FeedMemes.self,
            method: .get,
            encodingType: .json
        ) { model, errorMessage in
            if let model {
                completion(.success(model))
            } else {
                let message = path
                completion(.failure(.network(message)))
            }
        }
    }

    func getAiTempMemes(
        page: Int,
        completion: @escaping (Result<AITempResponse, ProfileError>) -> Void
    ) {
        let path = ProfileEndpoint.aiTempMemes(userId: AppStorage.shared.userId, page: page).path

        networkManager.request(
            path: path,
            model: AITempResponse.self,
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

    func fetchSubscriptionHistory(completion: @escaping (Result<SubscriptionHistory, ProfileError>) -> Void) {
        let path = ProfileEndpoint.paymentHistory.path

        networkManager.request(
            path: path,
            model: SubscriptionHistory.self,
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
