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
    func makeManageSubscription() -> UIViewController

    func makeMyMemes(router: MyMemesRouting) -> UIViewController
    func makeMyMemesGrid(mode: MyMemesMode) -> UIViewController

    func makeHelp(router: ProfileRouting) -> UIViewController
}

final class DefaultProfileFactory: ProfileFactory {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    private lazy var userRepository: UserRepositoryImp = {
        UserRepositoryImp(networkManager: networkManager)
    }()

    private lazy var userUseCase: UserUseCase = {
        UserUseCase(repository: userRepository)
    }()

    func makeProfile(router: ProfileRouting) -> UIViewController {
        let viewModel = ProfileVM(userUseCase: userUseCase)
        return ProfileViewController(viewModel: viewModel, router: router)
    }

    func makeEditProfile() -> UIViewController {
        let vm = ProfileVM(userUseCase: userUseCase)
        return EditProfileViewController(viewModel: vm)
    }

    func makePremium() -> UIViewController {
        let repo = PremiumRepositoryImpl(network: networkManager)
        let vm = PremiumVM(userId: AppStorage.shared.userId, repository: repo)
        return PremiumViewController(viewModel: vm)
    }

    func makeManageSubscription() -> UIViewController {
        let vm = ManageSubscriptionVM(userUseCase: userUseCase)
        return ManageSubscriptionVC(viewModel: vm)
    }

    func makeMyMemes(router: MyMemesRouting) -> UIViewController {
        let vm = MyMemesVM(userUseCase: userUseCase)

        let aiVC = MyMemesGridViewController(mode: .ai, viewModel: vm)
        let aiTempVC = MyMemesGridViewController(mode: .aiTemplate, viewModel: vm)

        let segments: [MyMemesSegmentItem] = [
            .init(title: MyMemesMode.ai.title, viewController: aiVC),
            .init(title: MyMemesMode.aiTemplate.title, viewController: aiTempVC)
        ]

        return MyMemesViewController(viewModel: vm, segments: segments)
    }

    func makeMyMemesGrid(mode: MyMemesMode) -> UIViewController {
        let vm = MyMemesVM(userUseCase: userUseCase)
        return MyMemesGridViewController(mode: mode, viewModel: vm)
    }

    func makeHelp(router: ProfileRouting) -> UIViewController {
        let vm = HelpFeedbackVM()
        return HelpFeedbackVC(viewModel: vm, router: router)
    }
}
