//
//  UserRepository.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

protocol UserRepository {
    func getUserProfile(
         completion: @escaping (Result<UserProfile, ProfileError>) -> Void
     )

     func updateProfile(
         _ request: UpdateProfileRequestDTO,
         completion: @escaping (Result<UserProfile, ProfileError>) -> Void
     )

    func getAiMemes(
        completion: @escaping (Result<FeedMemes, ProfileError>) -> Void
    )

    func getAiTempMemes(
        completion: @escaping (Result<AITempResponse, ProfileError>) -> Void
    )

    func fetchSubscriptionHistory(completion: @escaping (Result<SubscriptionHistory, ProfileError>) -> Void)
}
