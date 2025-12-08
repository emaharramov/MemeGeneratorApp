//
//  AIVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import UIKit
import Combine

final class AIVM: BaseViewModel {

    enum ViewState {
        case idle
        case memeLoaded(UIImage)
        case error(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var imageUrl: String?

    private let userId: String
    private let generateUseCase: GenerateAIMemeUseCaseProtocol
    private let loadImageUseCase: LoadAIMemeImageUseCaseProtocol

    init(
        userId: String,
        generateUseCase: GenerateAIMemeUseCaseProtocol,
        loadImageUseCase: LoadAIMemeImageUseCaseProtocol
    ) {
        self.userId = userId
        self.generateUseCase = generateUseCase
        self.loadImageUseCase = loadImageUseCase
        super.init()
    }

    func generateMeme(prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            let message = "Please enter an idea."
            state = .error(message)
            showError(message)
            return
        }

        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.generateUseCase.execute(
                    userId: self.userId,
                    prompt: trimmed,
                    completion: completion
                )
            },
            errorMapper: { [weak self] (error: AIMemeError) -> String in
                guard let self else { return "Something went wrong. Please try again." }

                let message = self.mapError(error)
                self.state = .error(message)
                return message
            },
            onSuccess: { [weak self] (urlString: String) in
                guard let self else { return }
                self.imageUrl = urlString
                self.loadImage(from: urlString)
            }
        )
    }

    private func loadImage(from urlString: String) {
        setLoading(true)

        loadImageUseCase.execute(urlString: urlString) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case .success(let image):
                self.state = .memeLoaded(image)
                self.showSuccess("Your meme is ready to serve! 🍽😂")

            case .failure(let error):
                let message = self.mapError(error)
                self.state = .error(message)
                self.showError(message)
            }
        }
    }

    private func mapError(_ error: AIMemeError) -> String {
        switch error {
        case .network(let raw):
            let message = decodeServerMessage(raw)
            return message.isEmpty
                ? "Something went wrong. Please try again."
                : message

        case .noMeme:
            return "No meme received. Please try again."

        case .imageDownloadFailed:
            return "Failed to load meme image. Please try again."
        }
    }
}
