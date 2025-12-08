//
//  PremiumRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 08.12.25.
//

protocol PremiumRepository {
    func syncPremium(
        request: SyncPremiumRequestDTO,
        completion: @escaping (Result<UserProfile, AIMemeError>) -> Void
    )
}
