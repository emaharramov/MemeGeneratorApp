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
            showAdForNonPremiumUser: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchProfile { result in
                    completion(result)
                }
            },
            errorMapper: { [weak self] (error: ProfileError) in
                guard let self else { return "Something went wrong. Please try again." }
                switch error {
                case .network(let rawMessage):
                    return self.decodeServerMessage(rawMessage)
                }
            },
            onSuccess: { [weak self] profile in
                self?.userProfile = profile
            }
        )
    }

    func updateProfile(
        avatarUrl: String,
        fullName: String,
        username: String,
        email: String
    ) {
        let request = UpdateProfileRequestDTO(
            avatarUrl: avatarUrl,
            fullName: fullName,
            username: username,
            email: email
        )

        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.updateProfile(request) { result in
                    completion(result)
                }
            },
            errorMapper: { [weak self] (error: ProfileError) in
                guard let self else { return "Something went wrong. Please try again." }

                switch error {
                case .network(let rawMessage):
                    return self.decodeServerMessage(rawMessage)
                }
            },
            onSuccess: { [weak self] updatedProfile in
                self?.userProfile = updatedProfile
                self?.showSuccess("Profile updated successfully ✅")
            }
        )
    }
}
