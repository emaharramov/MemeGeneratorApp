//
//  HomeFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol HomeFactory {
    func makeHome() -> UIViewController
}

final class HomeFeedFactory: HomeFactory {
    func makeHome() -> UIViewController {
        let networkManager = NetworkManager()
        let repository = FeedRepositoryImpl(networkManager: networkManager)
        let feedUseCase = FeedUseCase(repository: repository)
        let vm = FeedViewModel(getAllMemesUseCase: feedUseCase)
        let vc = FeedController(viewModel: vm)
        return vc
    }
}
