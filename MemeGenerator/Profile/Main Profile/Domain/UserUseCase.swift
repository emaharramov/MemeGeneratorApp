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
}
