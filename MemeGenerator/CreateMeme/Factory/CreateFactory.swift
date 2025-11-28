//
//  CreateFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol CreateFactory {
    func makeCreate(router: CreateRouting) -> UIViewController
    func makeAIMeme() -> UIViewController
    func makeAIWithTemplate() -> UIViewController
    func makeCustomMeme() -> UIViewController
    func makePremium() -> UIViewController
}

final class DefaultCreateFactory: CreateFactory {
    private let networkManager = NetworkManager()

    private lazy var authRepository: AuthRepository = {
        AuthRepositoryImpl(networkManager: networkManager)
    }()

    private lazy var loginUseCase: LoginUseCase = {
        LoginUseCaseImpl(repository: authRepository)
    }()

    private lazy var registerUseCase: RegisterUseCase = {
        RegisterUseCaseImpl(repository: authRepository)
    }()

    func makeCreate(router: CreateRouting) -> UIViewController {
        let vc = CreateViewController(router: router)
        return vc
    }

    func makeAIMeme() -> UIViewController {
        let vm = AIVM()
        let vc = AIVC(viewModel: vm)
        return vc
    }

    func makeAIWithTemplate() -> UIViewController {
        let vm = FromTemplateVM(userId: AppStorage.shared.userId)
        let vc = FromTemplateVC(viewModel: vm)
        return vc
    }

    func makeCustomMeme() -> UIViewController {
        let vm = UploadMemeViewModel(isPremiumUser: true)
        let vc = UploadMemeViewController(viewModel: vm)
        return vc
    }

    func makePremium() -> UIViewController {
        let vm = PremiumVM()
        let vc = PremiumViewController(viewModel: vm)
        return vc
    }
}
