//
//  ProfileVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation
import Combine

final class ProfileVM: BaseViewModel {

    private let userUseCase: UserUseCase
    @Published private(set) var userProfile: UserProfile?

    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        super.init()
    }

    func getUserProfile() {
        performWithLoading(
            resetMessages: true,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchProfile { result in
                    completion(result)
                }
            },
            errorMapper: { (error: ProfileError) in
                switch error {
                case .network(let message):
                    return message
                }
            },
            onSuccess: { [weak self] profile in
                self?.userProfile = profile
            }
        )
    }

    func updateProfile(
        fullName: String,
        username: String,
        email: String
    ) {
        let request = UpdateProfileRequestDTO(
            fullName: fullName,
            username: username,
            email: email
        )

        performWithLoading(
            resetMessages: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.updateProfile(request) { result in
                    completion(result)
                }
            },
            errorMapper: { (error: ProfileError) in
                switch error {
                case .network(let message):
                    return message
                }
            },
            onSuccess: { [weak self] updatedProfile in
                self?.userProfile = updatedProfile
                self?.showSuccess("Profile updated successfully ✅")
            }
        )
    }
}
