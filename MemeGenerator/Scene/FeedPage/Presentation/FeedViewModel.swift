//
//  FeedViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import Foundation
import Combine

final class FeedViewModel: BaseViewModel {

    private let useCase: FeedUseCase

    @Published private(set) var allAIMemes: [MemesTemplate] = []

    private var currentPage = 0
    private var hasNext = true

    init(getAllMemesUseCase: FeedUseCase) {
        self.useCase = getAllMemesUseCase
        super.init()
    }

    func loadPage(_ page: Int) {
        guard !isLoading else { return }

        if page == 1 {
            currentPage = 0
            hasNext = true
            allAIMemes = []
        }

        guard hasNext else { return }

        isLoading = true

        useCase.execute(page: page) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let feed):
                self.currentPage = page
                self.hasNext = feed.pageInfo?.hasNext ?? false

                if page == 1 {
                    self.allAIMemes = feed.memes ?? []
                } else {
                    self.allAIMemes.append(contentsOf: feed.memes ?? [])
                }

            case .failure(let error):
                switch error {
                case .network(let message):
                    self.showError(message)
                }
            }
        }
    }

    func loadNextPage() {
        loadPage(currentPage + 1)
    }
}
