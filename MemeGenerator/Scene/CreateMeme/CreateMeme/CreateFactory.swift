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
    func makeAuth() -> UIViewController
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
        let repository = AIMemeRepositoryImpl()
        let generateUseCase = GenerateAIMemeUseCase(repository: repository)
        let loadImageUseCase = LoadAIMemeImageUseCase(repository: repository)

        let viewModel = AIVM(
            userId: AppStorage.shared.userId,
            generateUseCase: generateUseCase,
            loadImageUseCase: loadImageUseCase
        )

        let vc = AIVC(viewModel: viewModel)
        return vc
    }

    func makeAIWithTemplate() -> UIViewController {
          let repository = FromTemplateRepositoryImpl()

          let loadTemplatesUseCase = LoadTemplatesUseCase(repository: repository)
          let generateMemeUseCase = GenerateMemeFromTemplateUseCase(repository: repository)

          let viewModel = FromTemplateVM(
              userId: AppStorage.shared.userId,
              loadTemplatesUseCase: loadTemplatesUseCase,
              generateMemeUseCase: generateMemeUseCase
          )
          let vc = FromTemplateVC(viewModel: viewModel)
          return vc
      }

    func makeCustomMeme() -> UIViewController {
        let templateRepository = FromTemplateRepositoryImpl()
        let uploadRepository = UploadMemeRepositoryImpl()

        let saveMemeUseCase = SaveMemeUseCase(repository: uploadRepository)
        let loadTemplatesUseCase = LoadTemplatesUseCase(repository: templateRepository)
        let loadTemplateImageUseCase = LoadTemplateImageUseCase(repository: templateRepository)

        let viewModel = UploadMemeViewModel(
            appWatermarkText: "MemeGenerator",
            saveMemeUseCase: saveMemeUseCase,
            loadTemplatesUseCase: loadTemplatesUseCase,
            loadTemplateImageUseCase: loadTemplateImageUseCase
        )

        let viewController = UploadMemeViewController(viewModel: viewModel)
        return viewController
    }

    func makePremium() -> UIViewController {
        let repo = PremiumRepositoryImpl(network: networkManager)
        let vm = PremiumVM(
            userId: AppStorage.shared.userId,
            repository: repo
        )
        let vc = PremiumViewController(viewModel: vm)
        return vc
    }

    func makeAuth() -> UIViewController {
        let vm = AuthViewModel(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase
        )

        let vc = AuthController(viewModel: vm, mode: .login)

        vm.onLoginSuccess = { [weak vc] _ in
            vc?.dismiss(animated: true)
        }

        vm.onRegisterSuccess = { [weak vc] _ in
            vc?.dismiss(animated: true)
        }

        return vc
    }
}
