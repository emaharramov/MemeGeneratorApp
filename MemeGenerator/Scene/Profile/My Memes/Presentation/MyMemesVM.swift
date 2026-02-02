//
//  MyMemesVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import Foundation
import Combine

final class MyMemesVM: BaseViewModel {

    private let userUseCase: UserUseCase

    @Published private(set) var aiMemes: FeedMemes?
    @Published private(set) var aiTempMemes: AITempResponse?

    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        super.init()
    }

    func getAiMemes(shouldRefreshProfile: Bool = true, page: Int = 1) {
        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.getAiMemes(page: page) { result in
                    completion(result)
                }
            },
            onSuccess: { [weak self] memes in
                guard let self else { return }
                self.aiMemes = memes
            }
        )
    }

    func getAiTemplateMemes(shouldRefreshProfile: Bool = true, page: Int = 1) {
        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.getAiTempMemes(page: page) { result in
                    completion(result)
                }
            },
            onSuccess: { [weak self] aiTempMemes in
                guard let self else { return }
                self.aiTempMemes = aiTempMemes
            }
        )
    }
}
