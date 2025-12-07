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
    func makeMyMemes(router: MyMemesRouting) -> UIViewController
    func makeHelp(router: ProfileRouting) -> UIViewController
    func makeAllMyMemes() -> UIViewController
    func makeAIMemes() -> UIViewController
    func makeAIMemesWithTemplate() -> UIViewController
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
        let repo = PremiumRepositoryImpl(network: networkManager)
        let vm = PremiumVM(
            userId: AppStorage.shared.userId,
            repository: repo,
        )
        let vc = PremiumViewController(viewModel: vm)
        return vc
    }

    func makeMyMemes(router: MyMemesRouting) -> UIViewController {
        let repository = UserRepositoryImp(networkManager: networkManager)
        let useCase = UserUseCase(repository: repository)
        let viewModel = MyMemesVM(userUseCase: useCase)
        let vc = MyMemesViewController(router: router, viewModel: viewModel)
        return vc
    }

    func makeHelp(router: ProfileRouting) -> UIViewController {
        let vm = HelpFeedbackVM()
        let vc = HelpFeedbackVC(viewModel: vm, router: router)
        return vc
    }

    private func makeMyMemesVM() -> MyMemesVM {
        let repository = UserRepositoryImp(networkManager: networkManager)
        let useCase = UserUseCase(repository: repository)
        return MyMemesVM(userUseCase: useCase)
    }

    func makeAllMyMemes() -> UIViewController {
        let vm = makeMyMemesVM()
        let vc = MyMemesGridViewController(mode: .all, viewModel: vm)
        return vc
    }

    func makeAIMemes() -> UIViewController {
        let vm = makeMyMemesVM()
        let vc = MyMemesGridViewController(mode: .ai, viewModel: vm)
        return vc
    }

    func makeAIMemesWithTemplate() -> UIViewController {
        let vm = makeMyMemesVM()
        let vc = MyMemesGridViewController(mode: .aiTemplate, viewModel: vm)
        return vc
    }
}
