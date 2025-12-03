//
//  FromTemplateVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import UIKit

@MainActor
final class FromTemplateVM: BaseViewModel {

    var onTemplatesLoaded: (([TemplateDTO]) -> Void)?
    var onMemeGenerated: ((UIImage?) -> Void)?
    var onError: ((String) -> Void)?

    private(set) var selectedTemplateId: String?

    private let userId: String
    private let loadTemplatesUseCase: LoadTemplatesUseCaseProtocol
    private let generateMemeUseCase: GenerateMemeFromTemplateUseCaseProtocol

    // Default init – içəridə repo/usecase-ləri özü yığır
    convenience init(userId: String) {
        let repository = FromTemplateRepositoryImpl()
        let loadTemplatesUseCase = LoadTemplatesUseCase(repository: repository)
        let generateMemeUseCase = GenerateMemeFromTemplateUseCase(repository: repository)

        self.init(
            userId: userId,
            loadTemplatesUseCase: loadTemplatesUseCase,
            generateMemeUseCase: generateMemeUseCase
        )
    }

    // DI üçün əsas init
    init(
        userId: String,
        loadTemplatesUseCase: LoadTemplatesUseCaseProtocol,
        generateMemeUseCase: GenerateMemeFromTemplateUseCaseProtocol
    ) {
        self.userId = userId
        self.loadTemplatesUseCase = loadTemplatesUseCase
        self.generateMemeUseCase = generateMemeUseCase
        super.init()
    }

    // MARK: - Templates

    func loadTemplates() {
        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.loadTemplatesUseCase.execute(completion: completion)
            },
            errorMapper: { [weak self] error in
                let message = error.localizedDescription
                self?.showError(message)
                self?.onError?(message)
                return message
            },
            onSuccess: { [weak self] templates in
                self?.onTemplatesLoaded?(templates)
            }
        )
    }

    func selectTemplate(id: String) {
        selectedTemplateId = id
    }

    func clearSelectedTemplate() {
        selectedTemplateId = nil
    }

    // MARK: - Generate Meme

    func generateMeme(prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            let message = "Please enter a prompt"
            showError(message)
            onError?(message)
            return
        }

        guard let templateId = selectedTemplateId else {
            let message = "Please select a template"
            showError(message)
            onError?(message)
            return
        }

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.generateMemeUseCase.execute(
                    userId: self.userId,
                    prompt: trimmed,
                    templateId: templateId,
                    completion: completion
                )
            },
            errorMapper: { [weak self] error in
                let message = error.localizedDescription
                self?.onError?(message)
                return message
            },
            onSuccess: { [weak self] image in
                self?.onMemeGenerated?(image)
            }
        )
    }
}
