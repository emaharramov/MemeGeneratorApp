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
    @Published private(set) var aiMemes: FeedMemes?
    @Published private(set) var aiTempMemes: AITempResponse?

    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        super.init()
    }

    func reloadProfile() {
        getUserProfile()
        getAiMemes(shouldRefreshProfile: false)
        getAiTemplateMemes(shouldRefreshProfile: false)
    }

    func getUserProfile(resetMessages: Bool = true) {
        performWithLoading(
            resetMessages: resetMessages,
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

    func getAiMemes(shouldRefreshProfile: Bool = true) {
        performWithLoading(
            resetMessages: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.getAiMemes { result in
                    completion(result)
                }
            },
            errorMapper: { (error: ProfileError) in
                switch error {
                case .network(let message):
                    return message
                }
            },
            onSuccess: { [weak self] memes in
                guard let self else { return }
                self.aiMemes = memes

                if shouldRefreshProfile {
                    self.getUserProfile(resetMessages: false)
                }
            }
        )
    }

    func getAiTemplateMemes(shouldRefreshProfile: Bool = true) {
        performWithLoading(
            resetMessages: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.getAiTempMemes { result in
                    completion(result)
                }
            },
            errorMapper: { (error: ProfileError) in
                switch error {
                case .network(let message):
                    return message
                }
            },
            onSuccess: { [weak self] aiTempMemes in
                guard let self else { return }
                self.aiTempMemes = aiTempMemes

                if shouldRefreshProfile {
                    self.getUserProfile(resetMessages: false)
                }
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
