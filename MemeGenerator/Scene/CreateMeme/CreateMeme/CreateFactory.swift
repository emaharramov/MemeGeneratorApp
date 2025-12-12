//
//  CreateFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol CreateFactory {
    func makeCreate(segments: [CreateSegmentItem]) -> UIViewController

    func makeAIMeme() -> UIViewController
    func makeAIWithTemplate() -> UIViewController
    func makeCustomMeme() -> UIViewController
}

final class DefaultCreateFactory: CreateFactory {

    func makeCreate(segments: [CreateSegmentItem]) -> UIViewController {
        CreateViewController(segments: segments)
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

        return AIVC(viewModel: viewModel)
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

        return FromTemplateVC(viewModel: viewModel)
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

        return UploadMemeViewController(viewModel: viewModel)
    }
}
