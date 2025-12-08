//
//  UserUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

final class UserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func fetchProfile(
        completion: @escaping (Result<UserProfile, ProfileError>) -> Void
    ) {
        repository.getUserProfile(completion: completion)
    }

    func updateProfile(
        _ request: UpdateProfileRequestDTO,
        completion: @escaping (Result<UserProfile, ProfileError>) -> Void
    ) {
        repository.updateProfile(request, completion: completion)
    }

    func getAiMemes(
        completion: @escaping (Result<FeedMemes, ProfileError>) -> Void
    ) {
        repository.getAiMemes(completion: completion)
    }

    func getAiTempMemes(
        completion: @escaping (Result<AITempResponse, ProfileError>) -> Void
    ) {
        repository.getAiTempMemes(completion: completion)
    }

    func fetchSubscriptionHistory (
        completion: @escaping (Result<SubscriptionHistory, ProfileError>) -> Void
    ) {
        repository.fetchSubscriptionHistory(completion: completion)
    }
}
