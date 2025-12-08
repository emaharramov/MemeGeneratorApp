//
//  FeedViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import Foundation
import Combine

final class FeedViewModel: BaseViewModel {

    private let getAllMemesUseCase: FeedUseCase
    @Published private(set) var allMemes: [MemesTemplate] = []

    init(getAllMemesUseCase: FeedUseCase) {
        self.getAllMemesUseCase = getAllMemesUseCase
        super.init()
    }

    func getAllMemes() {
        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.getAllMemesUseCase.execute { result in
                    completion(result)
                }
            },
            errorMapper: { error in
                switch error {
                case .network(let message):
                    return message
                }
            },
            onSuccess: { [weak self] feed in
                self?.allMemes = feed.memes ?? []
            }
        )
    }
}
