//
//  PremiumRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 07.12.25.
//

import Alamofire

final class PremiumRepositoryImpl: PremiumRepository {

    private let network: NetworkManager

    init(network: NetworkManager = NetworkManager()) {
        self.network = network
    }

    func syncPremium(
        request: SyncPremiumRequestDTO,
        completion: @escaping (Result<UserProfile, AIMemeError>) -> Void
    ) {
        let params: [String: Any] = [
            "userId": request.userId,
            "entitlementId": request.entitlementId,
            "productId": request.productId,
            "isActive": request.isActive,
            "expiresAt": request.expiresAt as Any
        ]
        let path = NetworkHelper.shared.configureURL(endpoint: "/users/premium/sync")

        network.request(
            path: path,
            model: UserProfile.self,
            method: .post,
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
}
