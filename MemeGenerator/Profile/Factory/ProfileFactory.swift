//
//  ProfileFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol ProfileFactory {
    func makeProfile(router: ProfileRouting) -> UIViewController
    func makeEditProfile() -> UIViewController
    func makePremium() -> UIViewController
    func makeMyMemes() -> UIViewController
    func makeHelp(router: ProfileRouting) -> UIViewController
}

final class DefaultProfileFactory: ProfileFactory {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func makeProfile(router: ProfileRouting) -> UIViewController {
        let repository = UserRepositoryImp(networkManager: networkManager)
        let useCase = UserUseCase(repository: repository)
        let viewModel = ProfileVM(userUseCase: useCase)
        let vc = ProfileViewController(viewModel: viewModel, router: router)
        return vc
    }

    func makeEditProfile() -> UIViewController {
        let repository = UserRepositoryImp(networkManager: networkManager)
        let useCase = UserUseCase(repository: repository)
        let vm = ProfileVM(userUseCase: useCase)
        let vc = EditProfileViewController(viewModel: vm)
        return vc
    }

    func makePremium() -> UIViewController {
        let vm = PremiumVM()
        let vc = PremiumViewController(viewModel: vm)
        return vc
    }

    func makeMyMemes() -> UIViewController {
        let vc = MyMemesViewController()
        return vc
    }

    func makeHelp(router: ProfileRouting) -> UIViewController {
        let vm = HelpFeedbackVM()
        let vc = HelpFeedbackVC(viewModel: vm, router: router)
        return vc
    }
}
